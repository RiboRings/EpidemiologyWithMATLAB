function SIS_Model_GUI

    Fig = figure('units', 'pixels', 'position', [100, 100, 1300, 610]);

    movegui(Fig, 'center')


    %%% the parameters
    tRange = [0, 50];
    N = 10000;

    I0 = 1;
    S0 = N - I0;
    beta = 0;
    gamma = 0;
    R_0 = beta * N / gamma;
    Tinf = 1 / gamma;

    Y0 = [S0; I0];

    %%% Solving the ODEs
    [tSol, YSol] = ode45(@SISmodel, tRange, Y0);

    S = YSol(:,1);
    I = YSol(:,2);


    %%% the coordinate system for the time development
    ax1 = axes(Fig, 'Units', 'pixels', 'position', [100, 220, 600, 350], 'xlim', tRange, 'ylim', [0, N]);

    pS = plot(tSol, S, 'b', 'LineWidth', 2, 'LineStyle', "-");
    hold on

    pI = plot(tSol, I, 'r', 'LineWidth', 2, 'LineStyle', "-");

    axis([tRange, 0, N])
    legend('S(t), susceptible', 'I(t), infected', 'Location', 'east')

    xlabel('time')
    ylabel('number of people')

    title({'\textbf{The SIS Model:} \quad $$\dot{S}=-\beta\, SI+\gamma I,\quad\dot{I}=\beta SI-\gamma I,\quad \dot{R}=\gamma I$$'}, 'interpreter', 'latex', 'FontSize', 12);
    hold off


    %%% Some Text
    TextAxes = axes(Fig, 'Units', 'pixels', 'position', [100, 220, 600, 350], 'xlim', [0 50], 'ylim', [0, 10000], 'Visible', 'off');

    text(52, -2500,'$$I(0)=$$', 'interpreter', 'latex', 'FontSize', 15,'Parent', TextAxes);
    text(54, -3800,'$$\beta =$$', 'interpreter', 'latex', 'FontSize', 15,'Parent', TextAxes);
    text(54, -5200,'$$\gamma =$$', 'interpreter', 'latex', 'FontSize', 15,'Parent', TextAxes);
    text(73.5, -2500,'$$N=$$', 'interpreter', 'latex', 'FontSize', 15,'Parent', TextAxes);
    text(68, -3800,'$$R_0 = \frac{\beta N}{\gamma}=$$', 'interpreter', 'latex', 'FontSize', 15, 'Parent', TextAxes);
    text(69.05, -5200,'$$T_{\mathrm{inf}} = \frac{1}{\gamma}=$$', 'interpreter', 'latex', 'FontSize', 15, 'Parent', TextAxes);

    Text_N = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position', [1036, 115, 100, 30], 'HorizontalAlignment', 'left', 'String', num2str(N));
    Text_R0 = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position', [1036, 70, 100, 30], 'HorizontalAlignment', 'left', 'String', num2str(R_0));
    Text_Tinf = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position', [1036, 20, 100, 30], 'HorizontalAlignment','left','String', num2str(Tinf));

   
    %%% The Phasespace 
    ax2 = axes(Fig, 'Units', 'pixels', 'position', [820, 220, 350, 350], 'xlim', [0, N], 'ylim', [0, N]);

    PhSp = plot(S, I, 'LineWidth', 2);
    hold on

    [s, i] = meshgrid (0:N / 25:N, 0:N / 25:N); 
    U = -beta .* s .* i + gamma * i;
    V = beta .* s .* i - gamma * i;
    L = sqrt(U.^2 + V.^2);
    VF = quiver(s, i, U ./ L, V ./ L, 0.5, 'k');

    axis([0, N, 0, N])
    xlabel('Susceptible')
    ylabel('Infected')

    title('\textbf{The Phase Space}', 'interpreter', 'latex', 'FontSize', 12)
    hold off


    %%%%%%%%%% Slider I0
    Slider_I0 = uicontrol('Style', 'slider', 'Position', [100, 120, 600, 30], 'Min', 0, 'Max', N - 1);
    addlistener(Slider_I0, 'Value', 'PostSet', @callbackfnI0);

    Text_I0 = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position', [790, 115, 100, 30], 'HorizontalAlignment', 'left', 'String', [num2str(1 + get(Slider_I0, 'Value')), ',']);

    function callbackfnI0(source, eventdata)
     
        I0 = ceil(get(eventdata.AffectedObject, 'Value')) + 1;
   
        S0 = N - I0;
        Y0 = [S0; I0];
   
        [tSol,YSol] = ode45(@SISmodel, tRange, Y0);

        pS.XData = tSol; pS.YData = YSol(:,1);
        pI.XData = tSol; pI.YData = YSol(:,2);
     
        PhSp.XData = YSol(:,1); PhSp.YData = YSol(:,2);
   
        Text_I0.String = [num2str(I0), ','];

    end


    %%%%%%%%%% Slider beta
    Slider_beta = uicontrol('Style', 'slider', 'Position', [100, 70, 600, 30], 'Min', 0, 'Max', 0.005);
    addlistener(Slider_beta, 'Value', 'PostSet', @callbackfnbeta);

    Text_beta = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position',[790 70 100 30], 'HorizontalAlignment', 'left', 'String', [num2str(get(Slider_beta, 'Value')), ',']);

    function callbackfnbeta(source, eventdata)
     
        beta = get(eventdata.AffectedObject, 'Value');
    
        [tSol, YSol] = ode45(@SISmodel, tRange, Y0);

        pS.XData = tSol; pS.YData = YSol(:,1);
        pI.XData = tSol; pI.YData = YSol(:,2);
    
        PhSp.XData = YSol(:,1); PhSp.YData = YSol(:,2);
    
        U = -beta .* s .* i + gamma * i;
        V = beta .* s .* i - gamma * i;
        L = sqrt(U.^2 + V.^2);
        VF.UData = U ./ L; VF.VData = V ./ L;
      
        R_0 = beta * N / gamma;
    
        Text_beta.String = [num2str(beta), ','];
        Text_R0.String = num2str(R_0);
    
    end


    %%%%%%%%%% Slider gamma
    Slider_gamma = uicontrol('Style', 'slider', 'Position', [100 20 600 30], 'Min', 0, 'Max', 2);
    addlistener(Slider_gamma, 'Value', 'PostSet', @callbackfngamma);

    Text_gamma = uicontrol(Fig, 'Style', 'text', 'FontSize', 13, 'position', [790 20 100 30], 'HorizontalAlignment', 'left', 'String', [num2str(get(Slider_gamma, 'Value')), ',']);

    function callbackfngamma(source, eventdata)
     
        gamma = get(eventdata.AffectedObject, 'Value');
        
        [tSol, YSol] = ode45(@SISmodel, tRange, Y0);

        pS.XData = tSol; pS.YData = YSol(:,1);
        pI.XData = tSol; pI.YData = YSol(:,2);
    
        PhSp.XData = YSol(:,1); PhSp.YData = YSol(:,2);
    
        U = -beta .* s .* i + gamma * i;
        V = beta .* s .* i - gamma * i;
        L = sqrt(U.^2 + V.^2);
        VF.UData = U ./ L; VF.VData = V ./ L;
    
        R_0 = beta * N / gamma;
        Tinf = 1 / gamma;
    
        Text_gamma.String = [num2str(gamma), ','];
        Text_R0.String = num2str(R_0);
        Text_Tinf.String = num2str(Tinf);
    
    end



    function dYdt = SISmodel(~, Y)

        %%% Extract S, I, and R from input vector Y
        S = Y(1); % susceptible
        I = Y(2); % infected
    
        %%% Define dSdt, dIdt, dRdt from the ODEs
        dSdt = -beta * S * I + gamma * I;
        dIdt = beta * S * I - gamma * I;
    
        %%% Create output column vector dYdt
        dYdt = [dSdt; dIdt];
    
    end

end