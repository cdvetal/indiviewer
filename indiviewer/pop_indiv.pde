class Individual {
  
  File file_image;
  String filename;
  PImage image;
  boolean image_requested = false;
  String genotype;
  
  Rectangle area = new Rectangle();
  boolean visible = true;
  boolean over = false;
  
  Population pop = null;
  int fitness = 0;
  boolean is_favourite = false;
  
  Individual(File file_image, String genotype) {
    this.file_image = file_image;
    filename = file_image.getName();
    this.genotype = genotype;
  }
  
  Individual(File file_image) {
    this(file_image, null);
  }
  
  void display() {
    if (visible == false) {
      return;
    }
    if (over) {
      float d = 3;
      fill(255);
      rect(area.x - d, area.y - d, area.w - 1 + d * 2, area.h - 1 + d * 2);
    }
    if (image != null && image.width > 0) {
      image(image, area.x, area.y, area.w, area.h);
    } else {
      noFill();
      stroke(128);
      strokeWeight(1);
      rect(area.x, area.y, area.w, area.h);
      line(area.x, area.y, area.x + area.w, area.y + area.h);
      line(area.x + area.w, area.y, area.x, area.y + area.h);
    }
    if (fitness != 0 || is_favourite) {
      textFont(font3);
      Rectangle r = new Rectangle(area.x, area.y, 0, 0);
      if (fitness != 0) {
        r = drawText(fitness + "", area.x, area.y, 0.05, -0.1, color(255, 80, 80), 255, "L");
      }
      if (is_favourite) {
        drawText("F", area.x, r.getBottom(), 0.05, -0.1, color(255, 255, 0), 0, "L");
      }
    }
  }
  
  Rectangle drawText(String text, float x, float y, float margin_hor, float margin_ver, color back, color front, String align_hor) {
    Rectangle bounds = new Rectangle(x, y, 0, 0);
    float text_w = textWidth(text + "");
    float text_h = textAscent() + textDescent();
    margin_hor *= text_h;
    margin_ver *= text_h;
    bounds.w = text_w + margin_hor * 2;
    bounds.h = text_h + margin_ver * 2;
    if (align_hor.equalsIgnoreCase("R")) {
      bounds.x -= bounds.w;
    }
    noStroke();
    fill(back);
    rect(bounds.x, bounds.y, bounds.w, bounds.h);
    fill(front);
    textAlign(CENTER, CENTER);
    text(text, bounds.getCentreX(), bounds.y + bounds.h * 0.35);
    return bounds;
  }
  
  void show() {
    if (image_requested == false && imageAvailable() == false) {
      image = requestImage(file_image.getAbsolutePath());
      image_requested = true;
    }
    visible = true;
  }

  void hide() {
    visible = false;
    image = null;
    image_requested = false;
  }
  
  void increaseFitness() {
    fitness += 1;
    dc.dataModified();
  }

  void decreaseFitness() {
    fitness = max(fitness - 1, 0);
    dc.dataModified();
  }
  
  void toggleFavourite() {
    is_favourite = !is_favourite;
    dc.dataModified();
  }
  
  boolean imageAvailable() {
    return image != null && image.width > 0;
  }
}

class Population {
  
  File dir;
  String dir_name;
  ArrayList<Individual> individuals = new ArrayList<Individual>();
  Rectangle area = new Rectangle(0, 0, 500, 500);
  
  Population(File dir) {
    this.dir = dir;
    this.dir_name = dir.getName();
  }

  void addIndividual(Individual i) {
    individuals.add(i);
    i.pop = this;
  }
  
  Individual getLastIndividual() {
    return individuals.get(individuals.size() - 1);
  }
}
