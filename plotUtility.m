function plotUtility(type, xdata, ydata1, ydata2, titleStr, xLabelStr, yLabelStr, legendStr1, legendStr2, filename)
    % plotUtility - A function to standardize the plotting process.
    figure;
    
    if strcmp(type, 'single')
        plot(xdata, ydata1,'Color', '#0072BD');
    elseif strcmp(type, 'dual')
        plot(xdata, ydata1, 'Color', '#0072BD', 'LineStyle', '-');
        hold on; 
        plot(xdata, ydata2, 'Color', '#EDB120', 'LineStyle', '-');
        hold off;
        legend(legendStr1, legendStr2);
    end
    
    title(titleStr);
    xlabel(xLabelStr);
    ylabel(yLabelStr);
    grid on;
    saveas(gcf, filename);
end