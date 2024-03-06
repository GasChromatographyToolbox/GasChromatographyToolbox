# GasChromatographyToolbox

This is the central repository for the tools I developed for the simulation of gas chromatographic (GC) separation in the Julia Programming Language. Different notebooks, using [Pluto.jl](https://github.com/fonsp/Pluto.jl), for this simulation will be collected here.  

The toolbox consists of the following parts:

![GasChromatographySimulator.jl](/assets/GasChromatographySimulator_logo.png)

[GasChromatographySimulator.jl](https://github.com/JanLeppert/GasChromatographySimulator.jl)

This is the base for the GC simulation. The migration and development of the peak width of several substances through a capillary column with a stationary phase is modeled by two ordinary differential equations (ODE). The model is described in detail in [Leppert](http://10.1016/j.chroma.2020.460985) and the package is presented in [Leppert2022](https://doi.org/10.21105/joss.04565).

![GasChromatographySystems.jl](/assets/GasChromatographySystems_logo.png)

[GasChromatographySystems.jl](https://github.com/JanLeppert/GasChromatographySystems.jl)

This package uses the GasChromatographySimulator.jl package to simulate the separation in complex GC systems, which consists of multiple capillary columns, e.g. multidimensional GC, GC×GC or multiple outlets at different pressures. It also works as a flow calculator for complex GC systems.

![RetentionParameterEstimator.jl](/assets/RetentionParameterEstimator_logo.png)

[RetentionParameterEstimator.jl](https://github.com/JanLeppert/RetentionParameterEstimator.jl)

This package uses the GasChromatographySimulator.jl package to estimate retention parameters from multiple GC measurement (temperature programmed and/or isothermal). The difference between measured and simulated retention times is minimized using a Newton method with trust regions, to determine the best fitting set of retention parameters. More information can be found in [Leppert2023](https://doi.org/10.1016/j.chroma.2023.464008).

![RetentionData](/assets/RetentionData_logo.png)

[RetentionData](https://github.com/JanLeppert/RetentionData)

This is not a Julia package, only a collection of retention data found in literature and from our measurements. Mor information can be found in [Brehmer2023](https://doi.org/10.1021/acsomega.3c01348).

## Notebooks

[Pluto notebooks](https://github.com/fonsp/Pluto.jl) are used as a simple user interface to use the GC simulation without the need to code yourself. To use these notebooks it is necessary to install the [Julia Programming Language](https://julialang.org/)

### Install Julia and Pluto

First [Julia, v1.6 or above,](https://julialang.org/downloads/#current_stable_release) must be installed for your operating system.

In a second step you have to start Julia and you have to add the **Pluto** package:

```julia
julia> import Pkg; Pkg.add(Pluto)
```

To run Pluto, use the following commands:

```julia
julia> using Pluto; Pluto.run();
```

Pluto will open your browser. In the field `Open from file` the URL of a notebook or the path to a locally downloaded notebook can be insert and the notebook will open and load the necessary packages.

An expanded tutorial can be found in this [PDF](https://github.com/JanLeppert/GasChromatographySimulator.jl/raw/main/InstallGuide.pdf).

### Overview of notebooks

* `simulation_conventional_GC.jl` ... Simulation of GC separation in one capillary column using [GasChromatographySimulator.jl](https://github.com/JanLeppert/GasChromatographySimulator.jl). Retention data from [RetentionData](https://github.com/JanLeppert/RetentionData) is used.
* `simulation_thermal_gradient_GC.jl` ... Simulation of GC separation in one capillary column with a thermal gradient along the column using [GasChromatographySimulator.jl](https://github.com/JanLeppert/GasChromatographySimulator.jl). Retention data from [RetentionData](https://github.com/JanLeppert/RetentionData) is used.