![GasChromatographyToolbox.jl](/assets/GasChromatographyToolbox_logo_w.png)

This is the central repository for the tools I developed for the simulation of gas chromatographic (GC) separation in the Julia Programming Language. Different notebooks, using [Pluto.jl](https://github.com/fonsp/Pluto.jl), for this simulation will be collected here.  

The toolbox consists of the following parts:

![GasChromatographySimulator.jl](/assets/GasChromatographySimulator_logo_w_s.png)

[GasChromatographySimulator.jl](https://github.com/GasChromatographyToolbox/GasChromatographySimulator.jl)

This is the base for the GC simulation. The migration and development of the peak width of several substances through a capillary column with a stationary phase is modeled by two ordinary differential equations (ODE). The model is described in detail in [[Leppert2020](https://doi.org/10.1016/j.chroma.2020.460985)] and the package is presented in [[Leppert2022](https://doi.org/10.21105/joss.04565)].

![GasChromatographySystems.jl](/assets/GasChromatographySystems_logo_w_s.png)

[GasChromatographySystems.jl](https://github.com/GasChromatographyToolbox/GasChromatographySystems.jl)

This package uses the GasChromatographySimulator.jl package to simulate the separation in complex GC systems, which consists of multiple capillary columns, e.g. multidimensional GC, GC×GC or multiple outlets at different pressures. It also works as a flow calculator for complex GC systems.

![RetentionParameterEstimator.jl](/assets/RetentionParameterEstimator_logo_w_s.png)

[RetentionParameterEstimator.jl](https://github.com/GasChromatographyToolbox/RetentionParameterEstimator.jl)

This package uses the GasChromatographySimulator.jl package to estimate retention parameters from multiple GC measurement (temperature programmed and/or isothermal). The difference between measured and simulated retention times is minimized using a Newton method with trust regions, to determine the best fitting set of retention parameters. More information can be found in [[Leppert2023](https://doi.org/10.1016/j.chroma.2023.464008)].

![RetentionData](/assets/RetentionData_logo_w_s.png)

[RetentionData](https://github.com/GasChromatographyToolbox/RetentionData)

This is not a Julia package, only a collection of retention data found in literature and from our measurements. Mor information can be found in [[Brehmer2023](https://doi.org/10.1021/acsomega.3c01348)].

## Notebooks

[Pluto notebooks](https://github.com/fonsp/Pluto.jl) are used as a simple user interface to use the GC simulation without the need to code yourself. To use these notebooks it is necessary to install the [Julia Programming Language](https://julialang.org/)

### Install Julia and Pluto

First, the latest stable version of  [Julia](https://julialang.org/downloads/#current_stable_release) must be installed for your operating system.

In a second step you have to start Julia and you have to add the **Pluto.jl** package. Start Julia by double-clicking the Julia executable or running `julia` from the command line to start an interactive session. Using the package manager Pkg you can add the Pluto.jl package as followed:

```julia
julia> import Pkg; Pkg.add(Pluto)
```

To run Pluto, use the following commands:

```julia
julia> using Pluto; Pluto.run();
```

Pluto will open your browser. In the field `Open from file` the URL of a notebook or the path to a locally downloaded notebook can be insert and the notebook will open in safe preview mode. To run the code of the notebook you have to click `Run notebook code` in the upper right corner. This finally starts the interactive notebook and load the necessary packages.

> :warning: **Running a notebook for the first time after installing Julia can take some time to download the needed packages to your system.** 

An expanded tutorial can be found in this [PDF](https://github.com/GasChromatographyToolbox/GasChromatographySimulator.jl/raw/main/InstallGuide.pdf). The notebook is than executed, by first loading the needed packages. In a first run, after installing Julia for the first time, this can take an extended amount of time because the packages and their dependencies have to be downloaded first. A later start of the notebook should be faster, but loading all the packages can take several 10s of seconds or even some minutes. 

### Overview of notebooks

* [`simulation_conventional_GC.jl`](https://github.com/GasChromatographyToolbox/GasChromatographyToolbox/blob/main/notebooks/simulation_conventional_GC.jl) ... Simulation of GC separation in one capillary column using [GasChromatographySimulator.jl](https://github.com/GasChromatographyToolbox/GasChromatographySimulator.jl). Retention data from [RetentionData](https://github.com/GasChromatographyToolbox/RetentionData) is used.
* [`simulation_thermal_gradient_GC.jl`](https://github.com/GasChromatographyToolbox/GasChromatographyToolbox/blob/main/notebooks/simulation_thermal_gradient_GC.jl) ... Simulation of GC separation in one capillary column with a thermal gradient along the column using [GasChromatographySimulator.jl](https://github.com/GasChromatographyToolbox/GasChromatographySimulator.jl). Retention data from [RetentionData](https://github.com/GasChromatographyToolbox/RetentionData) is used.
* [`estimate_retention_parameters.jl`](https://github.com/GasChromatographyToolbox/GasChromatographyToolbox/blob/main/notebooks/estimate_retention_parameters.jl) ... Estimation of retention parameters from measured chromatograms.