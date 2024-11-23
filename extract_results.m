% Extract data from folders
list = ls("*run");

folders_cell = regexpi(list, '(2024(_[0-9][0-9]){5}_run):', 'tokens', 'lineanchors');

gen2 = cell(13,3);
gen3 = cell(13,3);
gen4 = cell(13,3);
gen5 = cell(13,3);
gen6 = cell(13,3);
gen7 = cell(13,3);
gen8 = cell(13,3);
gen9 = cell(13,3);
gen10 = cell(13,3);
gen11 = cell(13,3);
gen12 = cell(13,3);
gen13 = cell(13,3);
gen14 = cell(13,3);
gen15 = cell(13,3);

cd("2024_05_03_19_48_06_run");
load("2024_05_03_19_48_06_run_results.mat");

i = 1;

gen2{i,1} = paths{2};
    gen3{i,1} = paths{3}; 
    gen4{i,1} = paths{4}; 
    gen5{i,1} = paths{5}; 
    gen6{i,1} = paths{6}; 
    gen7{i,1} = paths{7}; 
    gen8{i,1} = paths{8}; 
    gen9{i,1} = paths{9}; 
    gen10{i,1} = paths{10};
    gen11{i,1} = paths{11};
    gen12{i,1} = paths{12};
    gen13{i,1} = paths{13};
    gen14{i,1} = paths{14};
    gen15{i,1} = paths{15};

    gen2{i,2} = pdrs{2};
    gen3{i,2} = pdrs{3};
    gen4{i,2} = pdrs{4}; 
    gen5{i,2} = pdrs{5};
    gen6{i,2} = pdrs{6}; 
    gen7{i,2} = pdrs{7}; 
    gen8{i,2} = pdrs{8}; 
    gen9{i,2} = pdrs{9}; 
    gen10{i,2} = pdrs{10};
    gen11{i,2} = pdrs{11};
    gen12{i,2} = pdrs{12};
    gen13{i,2} = pdrs{13};
    gen14{i,2} = pdrs{14};
    gen15{i,2} = pdrs{15};

    gen2{i,3} = stats{2};
    gen3{i,3} = stats{3}; 
    gen4{i,3} = stats{4}; 
    gen5{i,3} = stats{5}; 
    gen6{i,3} = stats{6}; 
    gen7{i,3} = stats{7}; 
    gen8{i,3} = stats{8}; 
    gen9{i,3} = stats{9}; 
    gen10{i,3} = stats{10};
    gen11{i,3} = stats{11};
    gen12{i,3} = stats{12};
    gen13{i,3} = stats{13};
    gen14{i,3} = stats{14};
    gen15{i,3} = stats{15};

    cd("..");

for i = 2:length(folders_cell)
    disp(folders_cell{i});
    folder_string = string(folders_cell{i});
    cd(folder_string);
    results_file = strcat(folders_cell{i}, "_results.mat");
    load(results_file);
    
    gen2{i,1} = ans{2};
    gen3{i,1} = ans{3}; 
    gen4{i,1} = ans{4}; 
    gen5{i,1} = ans{5}; 
    gen6{i,1} = ans{6}; 
    gen7{i,1} = ans{7}; 
    gen8{i,1} = ans{8}; 
    gen9{i,1} = ans{9}; 
    gen10{i,1} = ans{10};
    gen11{i,1} = ans{11};
    gen12{i,1} = ans{12};
    gen13{i,1} = ans{13};
    gen14{i,1} = ans{14};
    gen15{i,1} = ans{15};    
    
    cd("..");

end

gen_results = {[] gen2 gen3 gen4 gen5 gen6 gen7 gen8 gen9 gen10 gen11 gen12 gen13 gen14 gen15};

gen_hops = {1, 15};
for i = 2:length(gen_results)
    processing_gen = gen_results{i};
    len_array = cellfun(@height, processing_gen);
    paths_rows_count = len_array(1,1);
    hops_per_node_in_gen = [table2array(processing_gen{1}(:,1))];
    for j = 1:length(processing_gen)
        hops_per_node_in_gen = [hops_per_node_in_gen table2array(processing_gen{j}(:,4))];
    end
    intermediate = standardizeMissing(hops_per_node_in_gen, 0)
    gen_hops{1, i} = standardizeMissing(intermediate, -1);
end

gen_stats = {1,15};

for i = 2:length(gen_hops)
    current_gen = gen_hops{i};
    stats_for_hops = [];
    for j = 1:height(current_gen)
        [node_min, node_max] = bounds(current_gen(j,2:end), "omitnan"); 
        node_mean = mean(current_gen(j,2:end), "omitnan");
        node_median = median(current_gen(j,2:end), "omitnan");
        node_std = std(current_gen(j,2:end), "omitnan");
        number_of_nans = sum(isnan(current_gen(j,2:end)));
        stats_for_hops = [stats_for_hops ; current_gen(j,1) node_min node_max node_mean node_std node_median number_of_nans (number_of_nans / 13)*100];
    end
       gen_stats{1, i} = stats_for_hops;
end
