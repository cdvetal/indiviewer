import java.io.FileWriter;
import java.io.IOException;

class EvolutionController {

  private File proxy_file;
  private boolean waiting_for_new_generation;
  private long time_last_check = 0;
  
  EvolutionController() {
    proxy_file = new File(input_dir_phenotypes, "_flag_to_evolve");
    waiting_for_new_generation = proxy_file.exists();
  }

  void update() {
    if (waitingForNewGeneration()) {
      if (millis() - time_last_check > 1000) {
        time_last_check = millis();
        if (proxy_file.exists() == false) {
          waiting_for_new_generation = false;
          onNewGenerationEvolved();
        }
      }
    }
  }
  
  void orderNewGeneration() {
    assert waitingForNewGeneration() == false;
    assert proxy_file.exists() == false;
    try {
      FileWriter fw = new FileWriter(proxy_file);
      fw.write(pops.get(pops.size() - 1).dir_name);
      fw.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    waiting_for_new_generation = true;
  }
  
  boolean waitingForNewGeneration() {
    return waiting_for_new_generation;
  }
}
