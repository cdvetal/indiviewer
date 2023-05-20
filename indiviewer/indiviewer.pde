import java.nio.file.Files;
import java.util.Arrays;

// ... /thecoin__run__2023_02_27__15_22_10_150__109937382532710400/images/all
File input_dir = new File("insert/here/your/path/with/populations");

ArrayList<Population> pops = new ArrayList<Population>();
ArrayList<Individual> all_indivs = new ArrayList<Individual>();

Individual indiv_selected = null;
boolean preview_indiv_selected = false;

int previous_width, previous_height;
long time_last_populations_load = -1;

boolean dark_scheme = true;
float pop_margin_top = 50;
int target_num_cols = 0;
int curr_num_cols;
float ui_unit;
PFont font1, font2, font3;

float scroll_target = 0;
float scroll_current = 0;
float scroll_gear = 10;

DataController dc;
EvolutionController ec;

void settings() {
  size(int(displayWidth * 0.8), int(displayHeight * 0.8));
  smooth(8);
  pixelDensity(displayDensity());
}

void setup() {
  frameRate(60);
  surface.setResizable(true);
  createExitHandler();
  loadIndividuals();
  dc = new DataController();
  ec = new EvolutionController();
}

void draw() {
  ec.update();
  dc.update();

  if (width != previous_width || height != previous_height) {
    previous_width = width;
    previous_height = height;
    prepareLayout();
  }

  if (frameCount == 1 || scroll_current != scroll_target) {
    if (abs(scroll_current - scroll_target) > 0.1) {
      scroll_current = scroll_current * 0.85 + scroll_target * 0.15;
    } else {
      scroll_current = scroll_target;
    }
    updateIndividualsVisibility();
  }

  background(dark_scheme ? 0 : 255);

  pushMatrix();
  translate(0, scroll_current);
  for (Individual i : all_indivs) {
    i.display();
  }
  pushStyle();
  fill(255);
  textFont(font1);
  textAlign(LEFT, CENTER);
  for (int p = 0; p < pops.size(); p++) {
    Population pop = pops.get(p);
    if (pop.individuals.get(0).visible) {
      String label = "/" + pop.dir_name + " (" + (p + 1) + "/" + pops.size() + ")";
      text(label, pop.area.x, pop.area.y + 1 * ui_unit);
    }
  }
  popStyle();
  popMatrix();

  /*pushMatrix();
   translate(0, scroll_current);
   pushStyle();
   noFill();
   strokeWeight(1);
   stroke(255, 0, 0);
   for (int p = 0; p < pops.size(); p++) {
   Population pop = pops.get(p);
   if (pop.individuals.get(0).visible) {
   rect(pop.area.x, pop.area.y, pop.area.w, pop.area.h);
   }
   }
   popStyle();
   popMatrix();*/

  if (preview_indiv_selected) {
    float margin = 20;
    float[] image_dim = resizeToFitInside(indiv_selected.image.width, indiv_selected.image.height, width - margin * 2, height - margin * 2);
    if (indiv_selected.image.width < image_dim[0]) {
      image_dim[0] = indiv_selected.image.width;
      image_dim[1] = indiv_selected.image.height;
    }
    pushStyle();
    noStroke();
    fill(g.backgroundColor, 200);
    rect(0, 0, width, height);
    /*rectMode(CENTER);
     noFill();
     strokeWeight(3);
     stroke(dark_scheme ? 255 : 0);
     rect(width / 2, height / 2, image_dim[0], image_dim[1]);*/
    fill(g.backgroundColor, 200);
    imageMode(CENTER);
    image(indiv_selected.image, width / 2, height / 2, image_dim[0], image_dim[1]);

    textFont(font2);
    textLeading(1.3 * g.textSize);
    textAlign(LEFT, TOP);
    fill(dark_scheme ? 255 : 0);
    text(indiv_selected.pop.dir_name + "/\n" + indiv_selected.filename, 1.2 * ui_unit, 1 * ui_unit);

    popStyle();
  }

  //bar.display();

  if (ec.waitingForNewGeneration()) {
    //float margin = ui_unit;
    float dim = ui_unit * 3;
    pushStyle();
    pushMatrix();
    translate(width / 2, height / 2);
    //translate(bar.bounds.getCentreX(), bar.bounds.getBottom() - dim * 1.5);
    rotate(millis() / 125f);
    noFill();
    //stroke(dark_scheme ? 255 : 0);
    stroke(255, 255, 0);
    strokeCap(SQUARE);
    strokeWeight(dim / 8);
    arc(0, 0, dim, dim, 0, HALF_PI);
    popMatrix();
    popStyle();
  }
}

void mouseMoved() {
  if (preview_indiv_selected) {
    return;
  }
  for (Individual i : all_indivs) {
    i.over = false;
  }
  indiv_selected = null;
  float mouseY_translated = mouseY - scroll_current;
  for (Individual i : all_indivs) {
    if (i.visible && i.area.contains(mouseX, mouseY_translated)) {
      indiv_selected = i;
      i.over = true;
      break;
    }
  }
}

void mouseReleased() {
  if (preview_indiv_selected) {
    preview_indiv_selected = false;
    return;
  }
  if (ec.waitingForNewGeneration() == false) {
    if (indiv_selected != null) {
      if (indiv_selected.pop == pops.get(pops.size() - 1)) {
        if (mouseButton == LEFT) {
          indiv_selected.increaseFitness();
        } else if (mouseButton == RIGHT) {
          indiv_selected.decreaseFitness();
        }
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (preview_indiv_selected) {
    return;
  }
  scroll_target -= event.getCount() * scroll_gear;
  Population last_pop = pops.get(pops.size() - 1);
  scroll_target = constrain(scroll_target, -(last_pop.area.getBottom() - height), 0);
}

void keyPressed() {
  if (key == ESC) {
    preview_indiv_selected = false;
    key = 0;
  }
}

void keyReleased() {
  if (key == CODED) {
    if (preview_indiv_selected == false) {
      int curr_pop = round(getCurrPop());
      if (keyCode == UP) {
        goToPop(max(curr_pop - 1, 0), true);
      } else if (keyCode == DOWN) {
        goToPop(min(curr_pop + 1, pops.size() - 1), true);
      } else if (keyCode == LEFT) {
        goToPop(0, true);
      } else if (keyCode == RIGHT) {
        goToPop(pops.size() - 1, true);
      }
    }
  } else {
    if (key == 'f') {
      if (indiv_selected != null) {
        indiv_selected.toggleFavourite();
      }
    } else if (key == 'b') {
      dark_scheme = !dark_scheme;
    } else if (key == 'o') {
      if (indiv_selected != null) {
        launch(indiv_selected.file_image.getPath());
      }
    } else if (key == ' ') {
      preview_indiv_selected = !preview_indiv_selected && indiv_selected != null && indiv_selected.imageAvailable();
    } else if (key == 'e') {
      if (ec.waitingForNewGeneration() == false) {
        Population last_pop = pops.get(pops.size() - 1);
        for (Individual i : last_pop.individuals) {
          if (i.fitness != 0) {
            ec.orderNewGeneration();
            break;
          }
        }
      }
    } else if (key == 'p') {
      saveFavouritesToFile();
    } else if (key == '+' || key == '-') {
      target_num_cols = curr_num_cols + (key == '+' ? -1 : 1);
      target_num_cols = max(target_num_cols, 1);
      prepareLayout();
    }
  }
}

void loadIndividuals() {
  int t = millis();

  // Clear populations loaded previously
  pops.clear();
  all_indivs.clear();

  // Find populations' folders
  ArrayList<File> pops_dirs = new ArrayList<File>();
  File[] files = input_dir.listFiles();
  Arrays.sort(files);
  for (int i = 0; i < files.length; i++) {
    File f = new File(files[i].getPath());
    if (f.isDirectory()) {
      pops_dirs.add(f);
    }
  }

  // For each population found in disk
  for (File pop_dir : pops_dirs) {

    // Find individuals' files
    ArrayList<File> indivs_files = new ArrayList<File>();
    files = pop_dir.listFiles();
    Arrays.sort(files);
    for (File f : files) {
      if (f.toPath().toString().toLowerCase().endsWith(".png")) {
        indivs_files.add(f);
      }
    }

    // Load individuals
    if (indivs_files.size() > 0) {
      Population new_pop = new Population(pop_dir);
      pops.add(new_pop);
      for (File f : indivs_files) {
        Individual new_indiv = new Individual(f);
        new_pop.addIndividual(new_indiv);
        all_indivs.add(new_indiv);
      }
    }
  }

  prepareLayout();

  goToPop(-1, false);

  println(all_indivs.size() + " individuals found in " + (millis() - t) + " ms");
}

void onNewGenerationEvolved() {
  dc.save();
  loadIndividuals();
  dc.load();
}

void prepareLayout() {
  ui_unit = max(height * 0.02, 15);
  font1 = createFont("fonts/Sono/Sono-Regular.ttf", 1 * ui_unit);
  font2 = createFont("fonts/Sono/Sono-Light.ttf", 1.5 * ui_unit);
  font3 = createFont("fonts/Sono/Sono-Medium.ttf", 1.2 * ui_unit);

  float pop_margin_top = 2.5 * ui_unit;
  float pop_margin_bottom = 1 * ui_unit;
  for (int p = 0; p < pops.size(); p++) {
    Population pop = pops.get(p);
    Grid grid = new Grid(pop.individuals.size(), 20, 20, false, false);
    float grid_y = (p == 0 ? 0 : pops.get(p - 1).area.getBottom()) + pop_margin_top;
    float grid_x = 20;
    float grid_w = width - grid_x * 2;
    //float grid_w = width - (bar_margin * 3 + bar_width);
    if (target_num_cols > 0) {
      grid.calculateForNCols(grid_x, grid_y, grid_w, target_num_cols);
    } else {
      grid.calculateToFit(grid_x, grid_y, grid_w, height - (pop_margin_top + pop_margin_bottom));
    }

    // Make sure each grid cell has a minimum size
    curr_num_cols = grid.cols;
    while (true) {
      if (grid.cells_list.get(0).w > 100) {
        break;
      }
      curr_num_cols--;
      grid.calculateForNCols(grid_x, grid_y, grid_w, curr_num_cols);
    }

    for (int i = 0; i < pop.individuals.size(); i++) {
      pop.individuals.get(i).area = grid.cells_list.get(i);
    }
    pop.area = grid.getBounds();
    pop.area.y -= pop_margin_top;
    pop.area.h += pop_margin_top + pop_margin_bottom;
  }

  scroll_gear = pops.get(pops.size() - 1).area.getBottom() / 10000f;
  scroll_gear = max(scroll_gear, 2);

  updateIndividualsVisibility();
}

void updateIndividualsVisibility() {
  for (Individual i : all_indivs) {
    if (i.area.y + scroll_target > -height && i.area.y + scroll_target < height * 2) {
      i.show();
    } else {
      i.hide();
    }
  }
}

void saveFavouritesToFile() {
  int num_favourites = 0;
  String output = "";
  for (Individual i : all_indivs) {
    if (i.is_favourite) {
      output += i.file_image.getPath().split(input_dir.getPath())[1] + "\n";
      num_favourites++;
    }
  }
  File output_file_favourites = new File(input_dir, "indiviewer_exported_favourites_" + System.currentTimeMillis() + ".csv");
  saveStrings(output_file_favourites.getPath(), new String[]{output.strip()});
  println(num_favourites + " favourites exported to: " + output_file_favourites.getPath());
}

float getCurrPop() {
  for (int i = 0; i < pops.size(); i++) {
    //if (pops.get(i).individuals.get(0).area.y >= -scroll_target) {
    if (pops.get(i).area.y >= -scroll_target) {
      return i;
    }
  }
  return 0;
}

void goToPop(int pop_index, boolean animate_scroll) {
  if (pop_index < 0) {
    pop_index = pops.size() + pop_index;
  }
  scroll_target = -pops.get(pop_index).area.y;
  if (animate_scroll == false) {
    scroll_current = scroll_target;
    updateIndividualsVisibility();
  }
}

void createExitHandler() {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run() {
      dc.saveIfNeeded();
    }
  }
  ));
}
