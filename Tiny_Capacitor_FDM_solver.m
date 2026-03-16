%% 1. INPUTS & PARAMETERS
% Define L, N, dx, and element index vars

L = 1; % matrix node length

% Epsilon (permittivity of vacuum)
epsilon0 = 8.854e-12; 


%INCREASE FOR GREATER RESOLUTION

N = 150; % Number of nodes 


dx = L/(N-1); % derivative equal to the length divided by one minus row length.
object_index = [0, NaN,  12, 0]; % Edge voltage, air voltage, plate1 voltage, Plate2 voltage


%% 2. MESH GENERATION (The Blueprint)
% Create the matrix (address locations) and mask_matrix (index labels).

matrix = zeros(N,N); % Build fundamental matrix
matrix = reshape(1:N^2, N, N); % Index all values on spatial matrix


rho = zeros(N, N); % Empty rho (charge density) matrix 


% MODIFY THIS CODE TO MODIFY GEOMETRY of charges in space

rho(60:70, 50:70) = 1e-9; % 1nC/square Charge in 10x10 piece of matrix (Shielded by faraday cage)


% Make matrix for capacitor indexing differentiating between grounded
% edges (0), air/vacuum (1), and capacitor plates (2).

mask_matrix = zeros(N,N); % Build identity Matrix for capacitor locations
mask_matrix(2:149,2:149) = 1; % Make air/Vacuum value 1


% MODIFY THIS CODE TO MODIFY GEOMETRY OF positive plates of capacitor system

mask_matrix(50:90,40:80) = 3; %Faraday cage Geometry
mask_matrix(55:85,45:75) = 1;
%mask_matrix(10:120,54:56) = 2; % Plate 1 value 2 (Capacitor)
%mask_matrix(10:15,54:56) = 2; % Ion thruster config (value 2)
%mask_matrix(20:25,54:56) = 2;
%mask_matrix(30:35,54:56) = 2;
%mask_matrix(40:45,54:56) = 2;
%mask_matrix(50:55,54:56) = 2;
%mask_matrix(60:65,54:56) = 2;


% MODIFY THIS CODE TO MODIFY GEOMETRY OF negative plates of capacitor system

%mask_matrix(20:110,60:62) = 3; % Plate 2 value 3 (Capacitor)
%mask_matrix(10:15,60:62) = 3; % Ion thruster config (value 3)
%mask_matrix(20:25,60:62) = 3;
%mask_matrix(30:35,60:62) = 3;
%mask_matrix(40:45,60:62) = 3;
%mask_matrix(50:55,60:62) = 3;
%mask_matrix(60:65,60:62) = 3;




%% 3. MATRIX ASSEMBLY (The Engine)
% Pre-allocate A (sparse) and b.
% Run nested for-loop to look at the mask and stamp the math.
global_dim = 5*N*N; % estimate of space required for sparse matrix
A_matrix = spalloc(N^2,N^2,global_dim); % Sparse constraint matrix A
b_vect(N^2,1) = 0; % B vector



%% 4. THE SOLVE (The Math)
% Run V = A \ b.
% Reshape the result.

A_matrix = speye(N^2, N^2); % Create sparse matrix for A matrix solver
b_vect = zeros(N^2, 1); % Initialize B vector with zeros for voltage.

% Make sure to tell user that if there are no charged plates, the solver
% will fail to output meaningful math.
%if max(mask_matrix(:)) < 2 
%    error('Wait! No charged plates (Label 2) found in the mask. Check your geometry.');
%end

% Nested For loop
for i = 2:N-1 % For row 1 to N
    for j = 2:N-1 % For column 1 to N
        k = matrix(i, j); % Temporary matrix value variable K
        m = mask_matrix(i, j); % object_index temporary variable m
        if m == 1 % If m is air conditions, create five point stencil
           A_matrix(k, k) = -4;
           A_matrix(k, k-N) = 1; 
           A_matrix(k, k+N) = 1; 
           A_matrix(k, k-1) = 1; 
           A_matrix(k, k+1) = 1; 
           b_vect(k) = -(rho(i,j)*dx^2) / epsilon0; % Note: Non-varying dx can be straight multiplication for this Poisson.
        else
           m = mask_matrix(i, j); % object_index temporary variable m
           if m ~= 1 %Condition to sort non-air objects out
                A_matrix(k, k) = 1; % Set that K to 1 for non-air objects.
           end
           if m == 0 || m ==3 % If edge or grounded plate set voltage to zero.
                b_vect(k) = 0;
           else % Else set to 12 volts.
                b_vect(k) = 12; 
           end
        end
    end
end

V_vec = A_matrix \ b_vect; % Run A=LU solver

V_final = reshape(V_vec, N, N); % Reshape into final matrix from vector.

V_final = real(V_final);


%% 5. POST-PROCESSING & PLOTTING (The Result)
% Create surf or contour plots.
% RUN THIS SECTION SPECIFICALLY FOR VOLTAGE MATRIX ONLY

imagesc(V_final); 
colorbar; 
title('The Final Voltage Matrix');

%% 6. Calculate E-field.
%E-field gradient calculation:

[Ex, Ey] = gradient(-V_final, dx); % Finds the gradient or first derivative of voltage as E = -dV/dx

E_field = sqrt(Ex.^2 + Ey.^2); % Element squaring (Pytagorean)
E_field = real(E_field);


imagesc(E_field); 
colorbar; 
title('The Final E-Field Matrix');



