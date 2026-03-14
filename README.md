# Tiny Capacitor FDM solver
This is a MATLAB based FDM solver for Electrostatic fields that can model capacitors in air or vacuum.

**The Technical Architecture:**

This solver uses the **Finite Difference Method (FDM)** to discretize Maxwell's equations (Laplace's Equation) onto a 2D grid.

### 1. Spatial Indexing
To bridge the gap between a 2D physical grid and 1D Linear Algebra, every $(i, j)$ coordinate is mapped to a unique global index $k$. This allows for a sparse $A$ matrix of size $N^2 \times N^2$.

### 2. Region Masking (Configurable Geometry)
The geometry is defined using a mask_matrix which acts as a blueprint for the solver. This makes the program highly configurable for different capacitor shapes:
* **Label 0:** Grounded Boundaries (Walls)
* **Label 1:** Air/Vacuum (Laplacian Stencil: $\nabla^2 V = 0$)
* **Label 2:** Plate 1 (Charged Electrode)
* **Label 3:** Plate 2 (Grounded/Reference Electrode)
  
* Note: Plate electrodes **can** be added if you modify object_index array.

### 3. Computational Efficiency
* **Sparse Storage:** Pre-allocated sparse matrices ensure the solver remains efficient for large matrices ($100 \times 100+$ nodes).
* **Matrix Assembly:** The system is solved using MATLAB's backslash operator ($\setminus$), utilizing optimized LU decomposition with this sparse system.
