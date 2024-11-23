function pos = visualize_provisioner_spread(gens, coordinates)
    provisioned = [];
    %plot_base_mesh(coordinates, provisioned);
    [renumerated_nodes, ~, ~, ~] = create_subnet(gens,15, coordinates);
    recalculated_nodes_neighbors = get_neighboring_nodes(renumerated_nodes, 6);
    for i=1:size(gens, 2)
        if(size(gens{i},1) > 0)
            fig = plot_base_mesh(coordinates, provisioned, recalculated_nodes_neighbors, renumerated_nodes);
            hold on;
            pos = get_node_positions(gens{i}, coordinates);
            scatter(pos(:,1), pos(:,2), 72, 'filled', 'MarkerFaceColor','#DC143C');
            xlabel("X-position (meters)");
            ylabel("Y-position (meters)");
            set(gca,'XMinorTick','on','YMinorTick','on');
            box on;
            %grid on;
            %grid minor;
            [nodes, ~, shell_indexes, shell_nodes] = create_subnet(gens, i, coordinates);
            if (shell_indexes == 1)
                shell_nodes = nodes;
            end
            text(shell_nodes(:,1) + 0.5, shell_nodes(:,2) + 0.5,  string(shell_indexes), 'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'FontSize',5);
            
            %origin point
            scatter(renumerated_nodes(1,1), renumerated_nodes(1,2), 72, 'filled', MarkerFaceColor='#7F00FF');
            text(renumerated_nodes(1,1) + 0.5, renumerated_nodes(1,2) + 0.5,  '1', 'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'FontSize',5);
            
            filename = string(datetime('now', 'format', 'uuuu.MM.dd_HH.mm.ss.SSS'));
            filename = append(int2str(i) , "_gen");
            filename = append(filename, ".tex");
            xlim([-4, 60]);
            ylim([-1.5, 35]);
            %saveas(fig, filename)
            matlab2tikz(convertStringsToChars(filename),'width', '13.5cm');
            close(fig);
            provisioned = [provisioned; gens{i}];
        end
    end
end

function fig = plot_base_mesh(coordinates, provisioned, recalc_neighbors, renumerated_nodes)
    fig = figure;
    for i = 1:size(renumerated_nodes)
        neighbors_for_i = recalc_neighbors{i}(:, 1);
        for j = 1:length(neighbors_for_i)
             line = [renumerated_nodes(i, 1) renumerated_nodes(i,2) ; renumerated_nodes(neighbors_for_i(j), 1), renumerated_nodes(neighbors_for_i(j), 2)];
            %[renumerated_nodes(i, :); renumerated_nodes(neighbors_index, :)]
             plot(line(:,1), line(:,2), "-", 'Color',"#000000");
             hold on;
        end
    end
    scatter(coordinates(:,1), coordinates(:,2), 72, 'filled', MarkerFaceColor="#0096FF");
    provisioned_pos = get_node_positions(provisioned, coordinates);
    if(~isempty(provisioned_pos))
        scatter(provisioned_pos(:,1), provisioned_pos(:,2), 72, 'filled', MarkerFaceColor='#228B22');
    end
end

function pos = get_node_positions(node_ids, coordinates)
    pos = [];
    for i = 1:size(node_ids, 1)
        pos = [pos; coordinates(node_ids(i), :)];
    end
end