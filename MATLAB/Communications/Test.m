TX_pos = [100 100 65];
Rdim = [300 300 300];
RX_pos = [25 25 0.5];
%Initialize
traceTX = zeros(1,2);
traceRX = zeros(1,2);
RX_vector = zeros(1,4);
for m = 1 : 2
    var = 1;
    if m == 1
        NodeRX_pos = RX_pos;
        NodeTX_pos = TX_pos;
    else
        NodeRX_pos = TX_pos;
        NodeTX_pos = RX_pos;
    end
    image_pos = pseudo(Rdim,NodeRX_pos);
    if m == 1
        TX_RX_image_pos = image_pos;
    elseif m == 2
        RX_TX_image_pos = image_pos;
    end
    %image_pos = [RX_pos;north_RX;west_RX;south_RX;east_RX;top_RX;bottom_RX]

    %disp('Image Position');
    %disp(image_pos);

    error = 5;
    
    % var = [RX N W S E T B] 
    for var = 1:7
    %----------------------------------------------------------------------
    %Receiver can not be on Axis.
        image_RX = image_pos(var,:);
        if image_RX(1) == NodeTX_pos(1)
            image_RX(1) = image_RX(1) + error;
        end
        if image_RX(2) == NodeTX_pos(2)
            image_RX(2) = image_RX(2) + error;
        end
        if image_RX(3) == NodeTX_pos(3)
            image_RX(3) = image_RX(3) + error;
        end
    %----------------------------------------------------------------------
        d = DistPlane(NodeTX_pos(1),NodeTX_pos(2),image_RX(1),image_RX(2));
    
        theta = (atan((image_RX(3)-NodeTX_pos(3))/d))*180/pi;
    
        if image_RX(1) > NodeTX_pos(1) && image_RX(2) > NodeTX_pos(2)
        
            phi = (atan((image_RX(2)-NodeTX_pos(2))/(image_RX(1)-NodeTX_pos(1))))*180/pi;
        
            quad = 1;
        elseif image_RX(1) < NodeTX_pos(1) && image_RX(2) > NodeTX_pos(2)
        
            phi = (atan((image_RX(2)-NodeTX_pos(2))/(NodeTX_pos(1)-image_RX(1))))*180/pi;
            phi = 180 - phi;
        
            quad = 2;
        elseif image_RX(1) < NodeTX_pos(1) && image_RX(2) < NodeTX_pos(2)
        
            phi = (atan((NodeTX_pos(2)-image_RX(2))/(NodeTX_pos(1)-image_RX(1))))*180/pi;
            phi = 180 + phi;
        
            quad = 3;
        elseif image_RX(1) > NodeTX_pos(1) && image_RX(2) < NodeTX_pos(2)
        
            phi = (atan((image_RX(1)-NodeTX_pos(1))/(NodeTX_pos(2)-image_RX(2))))*180/pi;
            phi = 270 + phi;
            quad = 4;
        end
        if m == 1
            traceTX(var,:) = [phi theta];
        elseif m == 2
            traceRX(var,:) = [phi theta];
        end
    end
end
%--------------------------------------------------------------------------
ObjectHit = [0 0 0 0];
%Objects = [Wall Window Door Opening]
Objects = [1 1 1 0];
NWindow = 2;
%East Wall & North Wall
WindowWall = [0 0 0 1;1 0 0 0];
WindowDim = [0.365 0.52 2.44 0.92];
%Door Detals
DoorWall = [0 1 0 0];
DoorLoc = 0; 
%Opening Details
Nopening = 0;
OpeningWall = [0 0 0 0];
OpenDim = [0 0];
[W O D] = WinOpenDoor(Objects,Rdim,NWindow,WindowWall,WindowDim,DoorWall,DoorLoc,Nopening,OpeningWall,OpenDim);
%--------------------------------------------------------------------------
TX_pos = TX_pos/100;
RX_pos = RX_pos/100;
Rdim = Rdim/100;
%Recever Postion
RF_R = RX_pos;
for j = 1:7
    phi = traceTX(j,1);
    theta = traceTX(j,2);
    phiRX = traceRX(j,1);
    thetaRX = traceRX(j,2);
    %LOS
    if j == 1
        RF_T = TX_pos;
        [NO1,NO2,E_tx] = gain(phi,theta);
        Rcoeff = 1;
        Phase_add = 0;
        d_pre = 0;
    %North Wall
    elseif j == 2
        [hitNorth,flag,E_tx] = north(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hitNorth(4) hitNorth(5) hitNorth(6)]; 
        Phase_add = hitNorth(7);
        Rcoeff = hitNorth(8);
        d_pre = hitNorth(9);
         if flag == 1
             disp('North');
             disp('Point of Conflict');
         end
    %West Wall    
    elseif j == 3
        [hitwest,flag,E_tx] = west(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hitwest(4) hitwest(5) hitwest(6)]; 
        Phase_add = hitwest(7);
        Rcoeff = hitwest(8);
        d_pre = hitwest(9);
         if flag == 1
             disp('West');
             disp('Point of Conflict');
         end
    %South Wall
    elseif j == 4
        [hitsouth,flag,E_tx] = south(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hitsouth(4) hitsouth(5) hitsouth(6)]; 
        Phase_add = hitsouth(7);
        Rcoeff = hitsouth(8);
        d_pre = hitsouth(9);
        if flag == 1
             disp('South');
             disp('Point of Conflict');
         end
    %East Wall
    elseif j == 5
        [hiteast,flag,E_tx] = east(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hiteast(4) hiteast(5) hiteast(6)]; 
        Phase_add = hiteast(7);
        Rcoeff = hiteast(8);
        d_pre = hiteast(9);
        if flag == 1
             disp('East');
             disp('Point of Conflict');
        end
    %Top Wall
    elseif j == 6
        [hittop,flag,E_tx] = top(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hittop(4) hittop(5) hittop(6)]; 
        Phase_add = hittop(7);
        Rcoeff = hittop(8);
        d_pre = hittop(9);
        if flag == 1
             disp('Top');
             disp('Point of Conflict');
        end
    %Bottom Wall
    elseif j == 7
        [hitbottom,flag,E_tx] = bottom(Rdim,TX_pos,phi,theta,W,O,D);
        %hit_____ = [Hit Refl_phi Refl_theta x y z phase Rcoeff]
        RF_T = [hitbottom(4) hitbottom(5) hitbottom(6)]; 
        Phase_add = hitbottom(7);
        Rcoeff = hitbottom(8);
        d_pre = hitbottom(9);
        %Receiver Gain Setting
        if flag == 1
             disp('Bottom');
             disp('Point of Conflict');
        end
    end
    %Receiver Gain Setting
    [Gain_coef] = gainRX(phiRX,thetaRX);
    %Phase
    beta = 50.4326;
    omegaC = 2*pi*2.44/0.3;
    d3D = Dist3D(RF_T(1),RF_T(2),RF_T(3),RF_R(1),RF_R(2),RF_R(3));
    phase = (omegaC - beta)*d3D*180/pi;
    NetPhase = rem((phase + Phase_add),360);
    %Total Distance
    d_total = d_pre + d3D;
    if j == 1
        E_rx = E_tx / d_total;
    else
        E_rx = (E_tx * d_pre) / d_total;
        E_rx = Rcoeff * E_rx;
    end
    E_rx = E_rx * Gain_coef;
    RX_vector(j,:) = [j E_rx Rcoeff NetPhase];
end
disp(RX_vector);
E_x_net = 0;
E_y_net = 0;
for n = 1 : 7
    E_x = RX_vector(n,2) * cos(RX_vector(n,4)*pi/180);
    E_y = RX_vector(n,2) * sin(RX_vector(n,4)*pi/180);
    E_x_net = E_x_net + E_x;
    E_y_net = E_y_net + E_y;
end
E_final = E_x_net^2 + E_y_net^2;
E_final = sqrt(E_final);
P_reception = E_final/(240*pi);
Pr = 10 * log10(P_reception);
disp('Received Power in db');
disp(Pr);
        
            
            
    
        
        
        