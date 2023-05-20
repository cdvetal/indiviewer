class DataController {

  private File data_file;
  private boolean saved = true;
  private long time_last_modification;
  private long save_delay = 10000;
  
  DataController() {
    data_file = new File(input_dir, "indiviewer.json");
    load();
    save(); // This is to remove old data in the JSON file (e.g. generations that don't exist anymore)
  }
  
  void update() {
    if (saved == false && time_last_modification + save_delay < millis()) {
      save();
    }
  }

  void load() {
    if (data_file.exists() == false) {
      return;
    }
    JSONObject json = loadJSONObject(data_file);
    JSONArray array_pops = json.getJSONArray("generations");
    for (int p = 0; p < array_pops.size(); p++) {
      if (p >= pops.size()) {
        break;
      }
      Population curr_pop = pops.get(p);
      JSONObject obj_pop = array_pops.getJSONObject(p);
      assert curr_pop.dir_name.equals(obj_pop.getString("dir_name"));
      JSONArray array_indivs = obj_pop.getJSONArray("individuals");
      for (int i = 0; i < array_indivs.size(); i++) {
        Individual curr_indiv = curr_pop.individuals.get(i);
        JSONObject obj_indiv = array_indivs.getJSONObject(i);
        assert curr_indiv.filename.equals(obj_indiv.getString("filename"));
        curr_indiv.fitness = obj_indiv.getInt("fitness");
        curr_indiv.is_favourite = obj_indiv.getBoolean("favorite", false);
      }
    }
    saved = true;
  }
  
  void save() {
    JSONObject json = new JSONObject();
    JSONArray array_pops = new JSONArray();
    for (int p = 0; p < pops.size(); p++) {
      Population curr_pop = pops.get(p);
      JSONObject obj_pop = new JSONObject();
      obj_pop.setString("dir_name", curr_pop.dir_name);
      JSONArray array_indivs = new JSONArray();
      for (int i = 0; i < curr_pop.individuals.size(); i++) {
        Individual curr_indiv = curr_pop.individuals.get(i);
        JSONObject obj_indiv = new JSONObject();
        obj_indiv.setString("filename", curr_indiv.filename);
        obj_indiv.setInt("fitness", curr_indiv.fitness);
        if (curr_indiv.is_favourite) {
          obj_indiv.setBoolean("favorite", curr_indiv.is_favourite);
        }
        array_indivs.setJSONObject(i, obj_indiv);
      }
      obj_pop.setJSONArray("individuals", array_indivs);
      array_pops.setJSONObject(p, obj_pop);
    }
    json.setJSONArray("generations", array_pops);
    saveJSONObject(json, data_file.getPath());
    saved = true;
  }
  
  void saveIfNeeded() {
    if (saved == false) {
      save();
    }
  }
  
  void dataModified() {
    saved = false;
    time_last_modification = millis();
  }
}
