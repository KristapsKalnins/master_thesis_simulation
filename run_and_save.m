
a = 0;
while a < 5
    current_directory = sprintf("%s_run", datetime('now'));
    mkdir(current_directory);
    run_simulation("layout_v2_bin.mat", 6, 2);
    cd(current_directory)
    results_string = sprintf("%s_results", current_directory);
    save(results_string);
    cd ..
    save_figures(current_directory);
    clearvars -except a;
    close all;
    a = a + 1;
end