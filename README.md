# IndiViewer

This is a Processing sketch to view individuals (images) created in an evolutionary process.

### Input files
File structure for phenotypes:
```
phenotypes/
├─ gen001/
│  ├─ gen001_indiv001.png
│  ├─ gen001_indiv002.png
│  ├─ gen001_indiv003.png
│  └─ ...
├─ gen002/
├─ gen003/
└─ ...
```
File structure for optional genotype preview:
```
genotypes/
├─ gen001.csv
├─ gen002.csv
├─ gen003.csv
└─ ...
```

### Interaction

Browse through the generations:
- Use the `scroll wheel` to scroll vertically through the generations;
- Press key `↑` to go to previous generation;
- Press key `↓` to go to next generation;
- Press key `←` to go to first generation;
- Press key `→` to go to last generation.

Assign fitness to individuals of last generation:
- Click on an individual with the `left button` to increase fitness;
- Click on an individual with the `right button` button to decrease fitness.

When hovering an individual with the mouse:
- Press key `f` to toggle the favourite flag;
- Press key `space bar` to preview the image (press again to close or use `escape`);
- Press key `o` to open the image file externally.

User interface:
- Press key `+` to increase individuals' size (make fewer individuals visible);
- Press key `-` to decrease individuals' size (make more individuals visible);
- Press key `g` to toggle genotype preview.
- Press key `b` to toggle dark scheme.

Input/output:
- Press key `e` to instruct external evolutionary engine to evolve new generation;
- Press key `p` to export csv file with favourite individuals. The file will be saved inside `dir_passed_as_input/`.
