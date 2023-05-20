class Grid {

  Rectangle bounds;
  int cols;
  int rows;
  float cell_size;
  int required_cells;
  float space_hor;
  float space_ver;
  boolean center_hor;
  boolean center_ver;
  ArrayList<Rectangle> cells_list;
  Rectangle[][] cells_table;

  Grid(int required_cells, float space_hor, float space_ver, boolean center_hor, boolean center_ver) {
    this.required_cells = required_cells;
    this.space_hor = space_hor;
    this.space_ver = space_ver;
    this.center_hor = center_hor;
    this.center_hor = center_ver;
  }

  void calculateToFit(float x, float y, float w, float h) {
    bounds = new Rectangle(x, y, w, h);
    cols = 0;
    rows = 0;
    cell_size = 0;

    while (cols * rows < required_cells) {
      cols += 1;
      cell_size = (w - (cols - 1) * space_hor) / cols;
      rows = floor(h / (cell_size + space_ver));
    }
    if (cols * (rows - 1) >= required_cells) {
      rows -= 1;
    }

    createCells();
  }

  void calculateForNCols(float x, float y, float w, int cols) {
    bounds = new Rectangle(x, y, w, 0);
    this.cols = cols;

    rows = 0;
    while (cols * rows < required_cells) {
      rows += 1;
    }

    cell_size = (w - (cols - 1) * space_hor) / cols;
    if (cols * (rows - 1) >= required_cells) {
      rows -= 1;
    }

    createCells();

    bounds.h = cells_list.get(cells_list.size() - 1).getBottom();
  }

  void createCells() {
    cells_list = new ArrayList<Rectangle>();
    cells_table = new Rectangle[rows][cols];

    float left_x = bounds.x;
    if (center_hor) {
      left_x = ((bounds.w - cols * cell_size) - (cols - 1) * space_hor) / 2;
      if (rows == 1 && cols > required_cells) {
        left_x = ((bounds.w - required_cells * cell_size) - (required_cells - 1) * space_hor) / 2;
      }
    }

    float top_y = bounds.y;
    if (center_ver && bounds.h > 0) {
      top_y = ((bounds.h - rows * cell_size) - (rows - 1) * space_ver) / 2;
      //top_y = min(left_x, top_y);
    }

    for (int row = 0; row < rows; row++) {
      float row_y = top_y + row * (cell_size + space_ver);
      for (int col = 0; col < cols; col++) {
        float col_x = left_x + col * (cell_size + space_hor);
        Rectangle new_cell = new Rectangle(col_x, row_y, cell_size, cell_size);
        cells_list.add(new_cell);
        cells_table[row][col] = new_cell;
        if (cells_list.size() >= required_cells) {
          break;
        }
      }
    }
  }

  Rectangle getBounds() {
    float x = cells_table[0][0].x;
    float y = cells_table[0][0].y;
    float w = cells_table[0][cols - 1].getRight() - x;
    float h = cells_table[rows - 1][0].getBottom() - y;
    return new Rectangle(x, y, w, h);
  }
}

/* ================================================================================ */
/* ================================================================================ */
/* ================================================================================ */

class Rectangle {

  float x = 0;
  float y = 0;
  float w = 0;
  float h = 0;

  Rectangle() {
  }

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  float getRight() {
    return x + w;
  }

  float getBottom() {
    return y + h;
  }

  float getCentreX() {
    return x + w / 2;
  }

  float getCentreY() {
    return y + h / 2;
  }

  boolean contains(float x, float y) {
    return x >= this.x && x < this.x + w && y >= this.y && y < this.y + h;
  }

  boolean intersects(Rectangle other) {
    return x < other.getRight() && getRight() > other.x && y > other.getBottom() && getBottom() < other.y;
  }
}

/* ================================================================================ */
/* ================================================================================ */
/* ================================================================================ */

float[] resizeToFitInside(float resize_w, float resize_h, float fit_w, float fit_h) {
  float aspect_ratio_resize = resize_w / resize_h;
  float aspect_ratio_fit = fit_w / fit_h;
  float x, y;
  if (aspect_ratio_fit >= aspect_ratio_resize) {
    x = fit_h * aspect_ratio_resize;
    y = fit_h;
  } else {
    x = fit_w;
    y = fit_w / aspect_ratio_resize;
  }
  return new float[]{x, y};
}

public static float[] resizeToFitOutside(float resize_w, float resize_h, float fit_w, float fit_h) {
  float aspect_ratio_resize = resize_w / resize_h;
  float aspect_ratio_fit = fit_w / fit_h;
  float x, y;
  if (aspect_ratio_fit >= aspect_ratio_resize) {
    x = fit_w;
    y = fit_w / aspect_ratio_resize;
  } else {
    x = fit_h * aspect_ratio_resize;
    y = fit_h;
  }
  return new float[]{x, y};
}

/* ================================================================================ */
/* ================================================================================ */
/* ================================================================================ */

float textHeight(String str, float specificWidth, float leading) {
  // https://forum.processing.org/one/topic/finding-text-height-from-a-text-area.html
  // split by new lines first
  String[] paragraphs = split(str, "\n");
  int numberEmptyLines = 0;
  int numTextLines = 0;
  for (int i=0; i < paragraphs.length; i++) {
    // anything with length 0 ignore and increment empty line count
    if (paragraphs[i].length() == 0) {
      numberEmptyLines++;
    } else {
      numTextLines++;
      // word wrap
      String[] wordsArray = split(paragraphs[i], " ");
      String tempString = "";
      for (int k=0; k < wordsArray.length; k++) {
        if (textWidth(tempString + wordsArray[k]) < specificWidth) {
          tempString += wordsArray[k] + " ";
        } else {
          tempString = wordsArray[k] + " ";
          numTextLines++;
        }
      }
    }
  }
  float totalLines = numTextLines + numberEmptyLines;
  return totalLines * leading;
}
