%% 1. INPUTS & PARAMETERS
% Define L, N, dx, and element index vars

L = 1; % matrix node length
N = 100; % Number of nodes
dx = L/(N-1); % derivative equal to the length divided by previous row.
object_index = [0, NaN,  12, 0]; % Edge voltage, air voltage, plate1 voltage, Plate2 voltage


%% 2. MESH GENERATION (The Blueprint)
% Create the matrix (address locations) and mask_matrix (index labels).

matrix = zeros(N,N); % Build fundamental matrix
matrix = reshape(1:N^2, N, N)'; % Index all values on spatial matrix


% Make matrix for capacitor indexing differentiating between grounded
% edges (0), air/vacuum (1), and capacitor plates (2).

mask_matrix = zeros(N,N); % Build identity Matrix for capacitor locations
mask_matrix(2:98,2:98) = 1; % Make air/Vacuum value 1

mask_matrix(10:90,10:12) = 2; % Plate 1 value 2
mask_matrix(10:90,20:22) = 2; % Plate 2 value 2



%% 3. MATRIX ASSEMBLY (The Engine)
% Pre-allocate A (sparse) and b.
% Run your nested for-loop to look at the mask and stamp the math.
global_dim = 5*N*N; % estimate of space required for sparse matrix
A_matrix = spalloc(N^2,N^2,global_dim); % Sparse constraint matrix A
b_vect(N^2,1) = 0; % B vector



%% 4. THE SOLVE (The Math)
% Run V = A \ b.
% Reshape the result.




%% 5. POST-PROCESSING & PLOTTING (The Result)
% Create your surf or contour plots.


