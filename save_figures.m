function save_figures(folder)
    FolderName = folder;   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        fprintf("Saving figure %d\n", iFig);
        FigHandle = FigList(iFig);
        FigName   = num2str(get(FigHandle, 'Number'));
        set(0, 'CurrentFigure', FigHandle);
        savefig(fullfile(FolderName, [FigName '.fig']));
    end
end