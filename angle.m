function [set_angle]=angle(Net,path_sets)
paths=size(path_sets,2)-1;
s_id=Net.s_d_id(1);
d_id=Net.s_d_id(2);
if paths==1 || paths==4
    set_angle=zeros(size(path_sets,1),1);
    return
end
for set=1:size(path_sets,1)
if paths==2
%pirma, pedeja hopa lenkis
        path_1=Net.node(s_id).route{path_sets(set,1)};
        path_2=Net.node(s_id).route{path_sets(set,2)};
        node1=path_1(2);
        node2=path_2(2);
        DirVector1=Net.positions(s_id,:)-Net.positions(node1,:);
        DirVector2=Net.positions(s_id,:)-Net.positions(node2,:);
        Angle=acos( dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2) )*180/pi;
        if Angle>180
            Angle=360-Angle;
        end
        set_angle(set,1)=Angle;
elseif paths==3        
        path_1=Net.node(s_id).route{path_sets(set,1)};
        path_2=Net.node(s_id).route{path_sets(set,2)};
        path_3=Net.node(s_id).route{path_sets(set,3)};
        node1=path_1(2);
        node2=path_2(2);
        node3=path_3(2);
        DirVector1=Net.positions(s_id,:)-Net.positions(node1,:);
        DirVector2=Net.positions(s_id,:)-Net.positions(node2,:);
        DirVector3=Net.positions(s_id,:)-Net.positions(node3,:);
        Angle(1)=acos( dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2) )*180/pi;
        if Angle(1)>180
            Angle(1)=360-Angle(1);
        end
        Angle(2)=acos( dot(DirVector2,DirVector3)/norm(DirVector2)/norm(DirVector3) )*180/pi;
        if Angle(2)>180
            Angle(2)=360-Angle(2);
        end
        Angle(3)=acos( dot(DirVector1,DirVector3)/norm(DirVector1)/norm(DirVector3) )*180/pi;
        if Angle(3)>180
            Angle(3)=360-Angle(3);
        end
        s_Angle=sort(Angle);
        a_Angle=mean(s_Angle(1:2));
        
        set_angle(set,1)=a_Angle;
end     
end