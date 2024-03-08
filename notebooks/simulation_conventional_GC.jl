### A Pluto.jl notebook ###
# v0.19.39

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 115b320f-be42-4116-a40a-9cf1b55d39b5
begin 
	nbname = replace(split(replace(@__FILE__, r"#==#.*" => ""), '/')[end], "_" => "\\_")
	# online version
	import Pkg
	version = "0.4.6"
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(name="CSV"),
		Pkg.PackageSpec(name="DataFrames"),
		Pkg.PackageSpec(name="GasChromatographySimulator", version=version),
		#Pkg.PackageSpec(name="GasChromatographySimulator", rev="fix_load_solute_database"),
        Pkg.PackageSpec(name="HypertextLiteral"),
		Pkg.PackageSpec(name="Plots"),
		Pkg.PackageSpec(name="PlutoUI"),
		Pkg.PackageSpec(name="UrlDownload"),
    ])
    using CSV, DataFrames,  GasChromatographySimulator, HypertextLiteral, Plots, PlutoUI, UrlDownload
	Markdown.parse("""
	online, $(nbname), for GasChromatographySimulator v$(version)
	""")

	# local version (database is still downloaded from github)
#=
	import Pkg
	# activate the shared project environment
	Pkg.activate(Base.current_project())
	using CSV, DataFrames,  GasChromatographySimulator, HypertextLiteral, Plots, PlutoUI, UrlDownload
	md"""
	local, Packages, simulation\_conventional\_GC.jl, for GasChromatographySimulator v0.4.1
	"""
=#
end

# ╔═╡ 9c54bef9-5b70-4cf7-b110-a2f48f5db066
begin
	html"""
	<style>
	  main {
		max-width: 800px;
	  }
	</style>
	"""
	TableOfContents()
end

# ╔═╡ c9246396-3c01-4a36-bc9c-4ed72fd9e325
md"""
# 
$(Resource("https://raw.githubusercontent.com/JanLeppert/GasChromatographySimulator.jl/main/docs/src/assets/logo_b.svg"))
A Simulation of a conventional Gas Chromatography (GC) System (without a thermal gradient).
"""

# ╔═╡ 8b3011fd-f3df-4ab0-b611-b943d5f3d470
md"""
# Settings
"""

# ╔═╡ 17966423-96f5-422f-9734-4ab0edab86bd
md"""
## Solute Database
Load own database: $(@bind own_db CheckBox(default=false))
"""

# ╔═╡ 3a076b77-5cd6-4e10-9714-7553d2822806
if own_db == true
	md"""
	$(@bind db_file FilePicker())
	"""
end

# ╔═╡ 51eb4859-20b9-4cac-bde4-ef30c6fea59d
md"""
## Program settings

Number of ramps: $(@bind n_ramp confirm(NumberField(0:1:100; default=3)))
"""

# ╔═╡ 052062dc-790c-4c08-96e4-ba6e0efeb2c4
md"""
## Substance settings
#### Substance categories
"""

# ╔═╡ 14db2d66-eea6-43b1-9caf-2039709d1ddb
md"""
### Peaklist
"""

# ╔═╡ 3c856d47-c6c2-40d3-b547-843f9654f48d
md"""
### Plot of local values

Plot $(@bind yy Select(["z", "t", "T", "τ", "σ", "u"]; default="t")) over $(@bind xx Select(["z", "t", "T", "τ", "σ", "u"]; default="z"))
"""

# ╔═╡ 95e1ca30-9442-4f39-9af0-34bd202fcc24
md"""
# End
"""

# ╔═╡ a0968f4b-b249-4488-a11b-dc109c68150f
begin
	if own_db == false
		db = DataFrame(urldownload("https://raw.githubusercontent.com/JanLeppert/RetentionData/main/Databases/GCSim_database_nonflag.csv"))
	else
		db = DataFrame(CSV.File(db_file["data"], silencewarnings=true, stringtype=String))
	end
	insertcols!(db, 1, :No => collect(1:length(db.Name)))
	sp = unique(db.Phase)
end;

# ╔═╡ ee04fde8-f0d6-4de3-91b2-b52855c180f4
db

# ╔═╡ 8c831fdb-0bfa-4f36-b720-e82fcf5d2427
function UI_Options()
	PlutoUI.combine() do Child
		@htl("""
		<h2>Option settings</h2>
		
		viscosity model: $(
			Child(Select(["HP", "Blumberg"]; default="Blumberg"))
		) control mode: $(
			Child(Select(["Pressure", "Flow"]; default="Flow"))
		)
		""")
	end
end

# ╔═╡ 0e2eba31-5643-4d10-9ed4-4454ec28df12
@bind opt_values confirm(UI_Options())

# ╔═╡ 115fa61e-8e82-42b2-8eea-9c7e21d97ea8
opt = GasChromatographySimulator.Options(;abstol=1e-8, reltol=1e-5, ng=true, vis=opt_values[1], control=opt_values[2]);

# ╔═╡ 678567a0-e00d-4883-b5a1-f21cbfc8bc33
function UI_Column(; default=(30.0, 0.25, 0.25, "He"))
		PlutoUI.combine() do Child
			@htl("""
			<h2>Column settings</h2>
			<i>L</i> [m]: $(
				Child(NumberField(0.1:0.1:100.0; default=default[1]))
			)  <i>d</i> [mm]: $(
				Child(NumberField(0.01:0.01:1.00; default=default[2]))
			)  <i>d</i><sub>f</sub> [µm]: $(
				Child(NumberField(0.01:0.01:1.00; default=default[3]))
			)  Gas: $(
				Child(Select(["He", "H2", "N2"]; default=default[4]))
			) 
			
			""")
	end
end

# ╔═╡ 0c3970ac-28f7-4bc4-b7eb-879dd719bd60
@bind col_values confirm(UI_Column())

# ╔═╡ 933791be-a0ac-4821-ae04-0475662b61d5
# decouple flow/pressure settings and temperature program
function UI_FProgram(opt)
	if opt.control == "Pressure"
		PlutoUI.combine() do Child
			@htl("""
			<ul>
				inlet pressure [kPa(g)]:
				$(Child(NumberField(0.0:0.1:1000.0; default=100.0)))
				<br>
				outlet pressure:
				$(Child(Select(["vacuum", "atmosphere"]; default="vacuum")))
			</ul>
			""")
		end
	elseif opt.control == "Flow"
		PlutoUI.combine() do Child
			@htl("""
			<ul>
				flow [mL/min]:
				$(Child(NumberField(0.0:0.1:100.0; default=1.0)))
				<br>
				outlet pressure:
				$(Child(Select(["vacuum", "atmosphere"]; default="vacuum")))
			</ul>
			""")
		end
	end
end

# ╔═╡ e4de755c-84ed-494f-9835-0f990ccd75a0
@bind Fprog_values confirm(UI_FProgram(opt))

# ╔═╡ 2b4d8f8a-3fc4-4df0-aed4-01963170d9bd
function UI_statphase(sp)
		PlutoUI.combine() do Child
			@htl("""
			stationary phase: $(
				Child(Select(sp))
			)
			""")
	end
end

# ╔═╡ fb6117fe-ed31-4a8b-8c35-9ccd28fe641a
@bind sp_value confirm(UI_statphase(sp))

# ╔═╡ 293ab0ef-bbad-4fc4-a12b-e69f69b1af69
begin
	sp_filter=filter([:Phase]=>(x)-> x.== sp_value[1], db)
	
	@bind cat_values confirm(MultiSelect(["all categories"; sort(unique(skipmissing([sp_filter.Cat_1 sp_filter.Cat_2 sp_filter.Cat_3])))]; default=["all categories"]))
end	

# ╔═╡ f7f06be1-c8fa-4eee-953f-0d5ea26fafbf
col = GasChromatographySimulator.Column(col_values[1], col_values[2]*1e-3, col_values[3]*1e-6, sp_value[1], col_values[4]);

# ╔═╡ c26c1ea7-575f-495d-86bc-987aca991664
function UI_TP(n_ramp)
	PlutoUI.combine() do Child
		@htl("""
		<table>
			<tr>
				<th>ramp [°C/min]</th>
				<th>T [°C]</th>
				<th>hold [min]</th>
			</tr>
			<tr>
				<td></td>
				<td><center>$(Child(NumberField(0.0:0.1:400.0; default=40.0)))</center></td>
				<td><center>$(Child(NumberField(0.0:0.1:100.0; default=1.0)))</center></td>
			</tr>
			$([
				@htl("
					<tr>
						<td><center>$(Child(NumberField(0.0:0.1:100.0; default=(i-1)*10.0 + 5.0)))</center></td>
						<td><center>$(Child(NumberField(0.0:0.1:400.0; default=((i+1)*100.0))))</center></td>
						<td><center>$(Child(NumberField(0.0:0.1:100.0; default=(i+1)*1.0)))</center></td>
					</tr>
				")
				for i=1:n_ramp
			])
		</table>
		""")
	end
end

# ╔═╡ f195738b-765c-449b-af10-f1686d656da6
@bind Tprog_values confirm(UI_TP(n_ramp))

# ╔═╡ c7b899a5-acb0-4994-98a8-b0dcd011b2f4
prog_values = (Tprog_values, Fprog_values...);

# ╔═╡ 5f5e16ec-2730-4a17-bd64-a751426a033f
begin
	TP_vector = collect(prog_values[1])
	time_steps, temp_steps = GasChromatographySimulator.conventional_program(TP_vector)
	if time_steps[1] == time_steps[2] && temp_steps[1] == temp_steps[2]
		time_steps = time_steps[2:end]
		temp_steps = temp_steps[2:end]
	end
	if opt.control=="Pressure"
		a = 101300.0
		b = 1000.0
	elseif opt.control=="Flow"
		a = 0.0
		b = 1/(6e7)
	end
	Fpin_steps = (a + b * prog_values[2]).*ones(length(time_steps))
	if prog_values[3] == "vacuum"
		pout_steps = zeros(length(time_steps))	
	elseif prog_values[3] == "atmosphere"
		pout_steps = 101300.0.*ones(length(time_steps))
	end
	prog = GasChromatographySimulator.Program( 	time_steps,
												temp_steps,
												Fpin_steps,
												pout_steps,
												col.L
												)
end;

# ╔═╡ 50f1bd7f-a479-453d-a8ea-57c37a4e330c
function UI_Program(n_ramp, opt)
	if opt.control == "Pressure"
		PlutoUI.combine() do Child
			@htl("""
			<ul>
				temperature program:
				<br>
				$(Child(UI_TP(n_ramp)))
				<br>
				inlet pressure [kPa(g)]:
				$(Child(NumberField(0.0:0.1:1000.0; default=100.0)))
				<br>
				outlet pressure:
				$(Child(Select(["vacuum", "atmosphere"]; default="vacuum")))
			</ul>
			""")
		end
	elseif opt.control == "Flow"
		PlutoUI.combine() do Child
			@htl("""
			<ul>
				temperature program:
				<br>
				$(Child(UI_TP(n_ramp)))
				<br>
				flow [mL/min]:
				$(Child(NumberField(0.0:0.1:100.0; default=1.0)))
				<br>
				outlet pressure:
				$(Child(Select(["vacuum", "atmosphere"]; default="vacuum")))
			</ul>
			""")
		end
	end
end

# ╔═╡ 088f1b80-2e70-41f7-a607-f2781354cf2d
function UI_Substance(sol; default=(1:4,))
	if length(sol)>10
		select_size = 10
	else
		select_size = length(sol)
	end
	if length(default) == 3
		PlutoUI.combine() do Child
			@htl("""
			<h4>Substance selection</h4> 
			
			Select from $(length(sol)) Substances: $(
				Child(MultiSelect(sol; default=sol[default[1]], size=select_size))
			) 
			Injection time [s]: $(
				Child(NumberField(0.0:0.1:100.0; default=default[2]))
			) and Injection width [s]: $(
				Child(NumberField(0.00:0.01:10.0; default=default[3]))
			) 
			""")
		end
	elseif length(default) == 1
		PlutoUI.combine() do Child
			@htl("""
			<h4>Substance selection</h4> 
			
			Select from  $(length(sol)) Substances: $(
				Child(MultiSelect(sol; default=sol[default[1]], size=select_size))
			) 
			""")
		end
	end
end

# ╔═╡ 83160876-bcdc-4286-afac-30ee9241fa9b
begin 	
	dbfilter = if cat_values == ["all categories"]
		sp_filter
	else	

		filter([:Cat_1, :Cat_2, :Cat_3]=>(x, y, z)-> occursin(string(x), string(cat_values)) || occursin(string(y), string(cat_values)) || occursin(string(z), string(cat_values)), sp_filter)
	end
	if size(dbfilter)[1] > 8
		n = 9
	else
		n = size(dbfilter)[1]
	end
	@bind sub_values confirm(UI_Substance(GasChromatographySimulator.all_solutes(sp_value[1], dbfilter; id=true); default=(1:n,))) 
end

# ╔═╡ e3277bb4-301a-4a1e-a838-311832b6d6aa
sub = GasChromatographySimulator.load_solute_database(db, col.sp, col.gas, GasChromatographySimulator.pares_No_from_sub_values(sub_values[1]), zeros(length(sub_values[1])), zeros(length(sub_values[1])));

# ╔═╡ 85954bdb-d649-4772-a1cd-0bda5d9917e9
par = GasChromatographySimulator.Parameters(col, prog, sub, opt)

# ╔═╡ fdb39284-201b-432f-bff6-986ddbc49a7d
begin
	plotly()
	plot_T = GasChromatographySimulator.plot_temperature(par; selector="T(t)")
	plot_p = GasChromatographySimulator.plot_pressure(par)
	xlabel!(plot_p, "")
	plot_F = GasChromatographySimulator.plot_flow(par)
	plot!(plot_T, xlabel="time in s", ylabel="temperature in °C")
	plot!(plot_p, guidefontsize=8)
	plot!(plot_F, guidefontsize=8)
	plot_empty = plot(grid=false)
	l1 = @layout([b{0.47h}; c{0.47h}])
	p_pF = plot(plot_p, plot_F, layout=l1)
	l = @layout([a{0.65w} d{0.35w}])
	p_TpF = plot(plot_T, p_pF, layout=l, size=(620,300))
	md"""
	### Plot of the program
	
	$(embed_display(p_TpF))
	"""
end

# ╔═╡ 49faa7ea-0f22-45ca-9ab5-338d0db25564
begin	
	peaklist, solution = GasChromatographySimulator.simulate(par)
	md"""
	# Simulation
	"""
end

# ╔═╡ 0f91abe2-11ae-4cf3-9126-656af1dba7a8
peaklist

# ╔═╡ a2287fe8-5aa2-4259-bf7c-f715cc866243
begin
	plotly()
	pchrom = GasChromatographySimulator.plot_chromatogram(peaklist, (0,sum(par.prog.time_steps)))[1]
	md"""
	### Chromatogram

	$(embed_display(pchrom))
	"""
end

# ╔═╡ 0740f2e6-bce0-4590-acf1-ad4d7cb7c523
begin
	plotly()
	GasChromatographySimulator.local_plots(xx, yy, solution, par)
end

# ╔═╡ 69cf18dd-a7b5-4f29-a8d2-e35420242db9
function export_str(opt_values, col_values, sp_value, prog_values, pl)
	opt_str_array = ["viscosity = $(opt_values[1])", "control = $(opt_values[2])"]
	opt_str = string(join(opt_str_array, ", "), "\n")
	
	col_str_array = ["L = $(col_values[1]) m", "d = $(col_values[2]) mm", "df = $(col_values[3]) µm", sp_value[1], "gas = $(col_values[4])"]
	col_str = string(join(col_str_array, ", "), "\n")

	if opt.control == "Pressure"
		prog_str_array = ["Program: $(prog_values[1])", "pin = $(prog_values[2]) kPa(g)", "outlet = $(prog_values[3])"]
	elseif opt.control == "Flow"
		prog_str_array = ["Program: $(prog_values[1])", "F = $(prog_values[2]) mL/min", "outlet = $(prog_values[3])"]
	end
	prog_str = string(join(prog_str_array, ", "), "\n")

	header = string(join(names(pl), ", "), "\n")

	pl_array = Array{String}(undef, length(pl.Name))
	for i=1:length(pl.Name)
		pl_array[i] = string(join(Matrix(pl)[i,:], ", "), "\n")
	end
	pl_str = join(pl_array)
	
	export_str = string("Option settings: \n", opt_str, "Column settings: \n", col_str, "Program settings: \n", prog_str, "Peaklist: \n", header, pl_str)
	return export_str
end

# ╔═╡ e8f84397-bd60-41a2-98c7-494873f6faf4
begin
	export_str_ = export_str(opt_values, col_values, sp_value, prog_values, peaklist)
	md"""
	## Export Results
	Filename: $(@bind result_filename TextField((20,1); default="Result.txt"))
	"""
end

# ╔═╡ 8cea4027-0987-4147-ac60-3b6bacb551ca
md"""
$(DownloadButton(export_str_, result_filename))
"""

# ╔═╡ Cell order:
# ╟─115b320f-be42-4116-a40a-9cf1b55d39b5
# ╟─9c54bef9-5b70-4cf7-b110-a2f48f5db066
# ╟─c9246396-3c01-4a36-bc9c-4ed72fd9e325
# ╟─8b3011fd-f3df-4ab0-b611-b943d5f3d470
# ╟─17966423-96f5-422f-9734-4ab0edab86bd
# ╟─3a076b77-5cd6-4e10-9714-7553d2822806
# ╟─ee04fde8-f0d6-4de3-91b2-b52855c180f4
# ╟─0e2eba31-5643-4d10-9ed4-4454ec28df12
# ╟─0c3970ac-28f7-4bc4-b7eb-879dd719bd60
# ╟─fb6117fe-ed31-4a8b-8c35-9ccd28fe641a
# ╟─51eb4859-20b9-4cac-bde4-ef30c6fea59d
# ╟─f195738b-765c-449b-af10-f1686d656da6
# ╟─e4de755c-84ed-494f-9835-0f990ccd75a0
# ╟─fdb39284-201b-432f-bff6-986ddbc49a7d
# ╟─052062dc-790c-4c08-96e4-ba6e0efeb2c4
# ╟─293ab0ef-bbad-4fc4-a12b-e69f69b1af69
# ╟─83160876-bcdc-4286-afac-30ee9241fa9b
# ╟─49faa7ea-0f22-45ca-9ab5-338d0db25564
# ╟─14db2d66-eea6-43b1-9caf-2039709d1ddb
# ╟─0f91abe2-11ae-4cf3-9126-656af1dba7a8
# ╟─a2287fe8-5aa2-4259-bf7c-f715cc866243
# ╟─3c856d47-c6c2-40d3-b547-843f9654f48d
# ╟─0740f2e6-bce0-4590-acf1-ad4d7cb7c523
# ╟─e8f84397-bd60-41a2-98c7-494873f6faf4
# ╟─8cea4027-0987-4147-ac60-3b6bacb551ca
# ╟─95e1ca30-9442-4f39-9af0-34bd202fcc24
# ╟─a0968f4b-b249-4488-a11b-dc109c68150f
# ╟─c7b899a5-acb0-4994-98a8-b0dcd011b2f4
# ╟─115fa61e-8e82-42b2-8eea-9c7e21d97ea8
# ╟─f7f06be1-c8fa-4eee-953f-0d5ea26fafbf
# ╟─5f5e16ec-2730-4a17-bd64-a751426a033f
# ╟─e3277bb4-301a-4a1e-a838-311832b6d6aa
# ╟─85954bdb-d649-4772-a1cd-0bda5d9917e9
# ╟─8c831fdb-0bfa-4f36-b720-e82fcf5d2427
# ╟─678567a0-e00d-4883-b5a1-f21cbfc8bc33
# ╟─50f1bd7f-a479-453d-a8ea-57c37a4e330c
# ╟─933791be-a0ac-4821-ae04-0475662b61d5
# ╟─2b4d8f8a-3fc4-4df0-aed4-01963170d9bd
# ╟─c26c1ea7-575f-495d-86bc-987aca991664
# ╟─088f1b80-2e70-41f7-a607-f2781354cf2d
# ╟─69cf18dd-a7b5-4f29-a8d2-e35420242db9
