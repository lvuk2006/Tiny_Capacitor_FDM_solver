%% 1. INPUTS & PARAMETERS
% Define L, N, dx, and element index vars

L = 1; % matrix node length
N = 150; % Number of nodes
dx = L/(N-1); % derivative equal to the length divided by previous row.
object_index = [0, NaN,  12, 0]; % Edge voltage, air voltage, plate1 voltage, Plate2 voltage


%% 2. MESH GENERATION (The Blueprint)
% Create the matrix (address locations) and mask_matrix (index labels).

matrix = zeros(N,N); % Build fundamental matrix
matrix = reshape(1:N^2, N, N); % Index all values on spatial matrix


% Make matrix for capacitor indexing differentiating between grounded
% edges (0), air/vacuum (1), and capacitor plates (2).

mask_matrix = zeros(N,N); % Build identity Matrix for capacitor locations
mask_matrix(2:149,2:149) = 1; % Make air/Vacuum value 1

mask_matrix(10:120,54:56) = 2; % Plate 1 value 2
mask_matrix(10:120,60:62) = 3; % Plate 2 value 2



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
if max(mask_matrix(:)) < 2 
    error('Wait! No charged plates (Label 2) found in the mask. Check your geometry.');
end

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
           b_vect(k) = 0;
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



%% 5. POST-PROCESSING & PLOTTING (The Result)
% Create surf or contour plots.
% Calculate E-field.
imagesc(V_final); 
colorbar; 
title('The Final Matrix');

