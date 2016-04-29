    function fig=draw_routes(Net,con,fig)
    
   
%    figure
%     for n=1:active
%         kordinates=Net.node(n).position.InitialPosition;
%         plot(kordinates(1),kordinates(2), 'o', 'MarkerSize',20,'LineWidth',1), grid on
%         text('String',num2str(n),'Position',[kordinates(1)+2 kordinates(2)+2],'FontSize',10);
%         %text('Parent',axes1,'String','12','Position',[-41.935592761416 21.0989719405628 0],'FontSize',10);
%         %set(te,'FontSize',10)
%         hold on
%     end
%fig=figure;

hold on
   
               
               
    
    
    for k=1:size(con)
        x1=Net.node(con(k,1)).position.InitialPosition(1);
        x2=Net.node(con(k,2)).position.InitialPosition(1);
        y1=Net.node(con(k,1)).position.InitialPosition(2);
        y2=Net.node(con(k,2)).position.InitialPosition(2);
        
        %if k=1
            
%         x1=kordinates(con(k,1),1);
%         x2=kordinates(con(k,2),1);
%         y1=kordinates(con(k,1),2);
%         y2=kordinates(con(k,2),2);
      
        myline=line([x1 x2],[y1 y2],'LineStyle','--','Tag','linija','LineWidth',1);
        %set(myline,'LineStyle','--','Tag','linija');
       % x=(min([x1 x2])+(abs(x1-x2))/2)/100;
      %  y=(min([y1 y2])+(abs(y2-y1))/2)/100;
        % txtar=annotation('textbox',[x y 0.1 0.1],'String',con(k,3))
        %     axis([-10 110 -10 110]);
        
    end
    
   % title(['Nodu skaits:',num2str(num_nodes),'  links:',num2str(links),'(',num2str(max_link),')','  Generation:',num2str(iter),'  checks:',num2str(checks)])
    hold off
%subplot(1,2,2);
 % plot(1:iter,link_list, 1:iter, max_link),grid on;
  
  
    
   

    drawnow;% pause(0.1);
    end