
########## OTS variables ###########
function variable_dc_branch_indicator(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, relax::Bool=false, report::Bool=true)
    if !relax
        z_ots_dc_var = _PM.var(pm, nw)[:z_ots_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :branchdc)], base_name="$(nw)_z_ots_dc",
            binary = true,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "z_ots_start_dc", 1.0)
        )
    else
        z_ots_dc_var = _PM.var(pm, nw)[:z_ots_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :branchdc)], base_name="$(nw)_z_ots_dc",
            lower_bound = 0.0,
            upper_bound = 1.0,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "z_ots_start_dc", 1.0)
        )
    end

    report && _PM.sol_component_value(pm, nw, :branchdc, :br_status, _PM.ids(pm, nw, :branchdc), z_ots_dc_var)
end

function variable_dc_branch_indicator_one(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, relax::Bool=false, report::Bool=true)
    if !relax
        z_ots_dc_var = _PM.var(pm, nw)[:z_ots_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :branchdc)], base_name="$(nw)_z_ots_dc",
            binary = false,
            lower_bound = 1.0,
            upper_bound = 1.0,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "z_ots_start_dc", 1.0)
        )
    else
        z_ots_dc_var = _PM.var(pm, nw)[:z_ots_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :branchdc)], base_name="$(nw)_z_ots_dc",
            lower_bound = 0.0,
            upper_bound = 1.0,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "z_ots_start_dc", 1.0)
        )
    end

    report && _PM.sol_component_value(pm, nw, :branchdc, :br_status, _PM.ids(pm, nw, :branchdc), z_ots_dc_var)
end


function variable_dc_conv_indicator(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, relax::Bool=false, report::Bool=true)
    if !relax
        z_ots_conv_DC_var = _PM.var(pm, nw)[:z_conv_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :convdc)], base_name="$(nw)_z_conv_DC",
            binary = true,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :convdc, l), "z_conv_start_DC", 1.0)
        )
    else
        z_ots_conv_DC_var = _PM.var(pm, nw)[:z_conv_dc] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :convdc)], base_name="$(nw)_z_conv_DC",
            lower_bound = 0.0,
            upper_bound = 1.0,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :convdc, l), "z_conv_start_DC", 1.0)
        )
    end

    report && _PM.sol_component_value(pm, nw, :convdc, :conv_status, _PM.ids(pm, nw, :convdc), z_ots_conv_DC_var)
end

########## Busbar splitting variables ###########
# AC grid -> no need for new variables, already implemented in PowerModels

# DC grid
function variable_dc_switch_indicator(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, relax::Bool=false, report::Bool=true)
    if !relax
        z_dcswitch = _PM.var(pm, nw)[:z_dcswitch] = JuMP.@variable(pm.model,
            [i in _PM.ids(pm, nw, :dcswitch)], base_name="$(nw)_z_dcswitch",
            binary = true,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :dcswitch, i), "z_dcswitch_start", 1.0)
        )
    else
        z_dcswitch = _PM.var(pm, nw)[:z_dcswitch] = JuMP.@variable(pm.model,
            [i in _PM.ids(pm, nw, :dcswitch)], base_name="$(nw)_z_dcswitch",
            lower_bound = 0,
            upper_bound = 1,
            start = _PM.comp_start_value(ref(pm, nw, :dcswitch, i), "z_dcswitch_start", 1.0)
        )
    end

    report && _PM.sol_component_value(pm, nw, :dcswitch, :status, _PM.ids(pm, nw, :dcswitch), z_dcswitch)
end

#=
p = _PM.var(pm, nw)[:p_dcgrid] = JuMP.@variable(pm.model,
[(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_pdcgrid",
start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 1.0)
)
=#

function variable_dc_switch_test(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, bounded::Bool = true, report::Bool=true)
    p_test = _PM.var(pm, nw)[:p_test] = JuMP.@variable(pm.model,
    [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_pdcgrid",
    start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 1.0)
    )

    if bounded
        for arc in _PM.ref(pm, nw, :arcs_dcgrid)
            l,i,j = arc
            JuMP.set_lower_bound(p_test[arc], -_PM.ref(pm, nw, :branchdc, l)["rateA"])
            JuMP.set_upper_bound(p_test[arc],  _PM.ref(pm, nw, :branchdc, l)["rateA"])
        end
    end

    report && _IM.sol_component_value_edge(pm, _PM.pm_it_sym, nw, :branchdc, :pf, :pt, _PM.ref(pm, nw, :arcs_dcgrid_from), _PM.ref(pm, nw, :arcs_dcgrid_to), p_test)
end

function variable_active_dcbranch_flow(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, bounded::Bool = true, report::Bool=true)
    p = _PM.var(pm, nw)[:p_dcgrid] = JuMP.@variable(pm.model,
    [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_pdcgrid",
    start = _PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 1.0)
    )

    if bounded
        for arc in _PM.ref(pm, nw, :arcs_dcgrid)
            l,i,j = arc
            JuMP.set_lower_bound(p[arc], -_PM.ref(pm, nw, :branchdc, l)["rateA"])
            JuMP.set_upper_bound(p[arc],  _PM.ref(pm, nw, :branchdc, l)["rateA"])
        end
    end

    report && _IM.sol_component_value_edge(pm, _PM.pm_it_sym, nw, :branchdc, :pf, :pt, _PM.ref(pm, nw, :arcs_dcgrid_from), _PM.ref(pm, nw, :arcs_dcgrid_to), p)
end
#=
function variable_branch_indicator_linear(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, bounded::Bool = true, report::Bool=true)
    z_branch_linear = _PM.var(pm, nw)[:z_branch_linear] = JuMP.@variable(pm.model,
            [l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_z_branch_linear",
            lower_bound = 0.0,
            upper_bound = 1.0,
            start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "z_branch_linear_start", 1.0)
        )
    report && _PM.sol_component_value(pm, nw, :branch, :br_status, _PM.ids(pm, nw, :branch), z_branch_linear)
end
=#

function variable_branch_indicator_linear(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, relax::Bool=false, report::Bool=true)
    br = Dict()
    for l in _PM.ids(pm, nw, :branch)
        br[l] = _PM.ref(pm,nw,:branch,l)
    end    
    
    z_branch = _PM.var(pm, nw)[:z_branch] = JuMP.@variable(pm.model,
    [l in _PM.ids(pm, nw, :branch)], base_name="$(nw)_z_branch",
    binary = false,
    lower_bound = 0,
    upper_bound = 1,
    start = _PM.comp_start_value(_PM.ref(pm, nw, :branch, l), "z_branch_start", br[l]["br_status_initial"])
    )

    report && _PM.sol_component_value(pm, nw, :branch, :br_status, _PM.ids(pm, nw, :branch), z_branch)
end














"variable: `p_dc_sw[l,i,j]` for `(l,i,j)` in `arcs_dc_sw`"
function variable_dc_switch_power(pm::_PM.AbstractPowerModel; nw::Int=_PM.nw_id_default, bounded::Bool=true, report::Bool=true)
    #p_dc_sw_ = _PM.var(pm, nw)[:p_dc_sw] = JuMP.@variable(pm.model,
    p_dc_sw_ = JuMP.@variable(pm.model,
        [(l,i,j) in _PM.ref(pm, nw, :arcs_from_sw_dc)], base_name="$(nw)_p_dc_sw",
        start = _PM.comp_start_value(_PM.ref(pm, nw, :dcswitch, l), "p_dc_sw_start", 1.0)
    )
    
    if bounded
        flow_lb, flow_ub = _PM.ref_calc_switch_flow_bounds(_PM.ref(pm, nw, :dcswitch), _PM.ref(pm, nw, :busdc))
        for arc in _PM.ref(pm, nw, :arcs_from_sw_dc)
            l,i,j = arc
            if !isinf(flow_lb[l])
                JuMP.set_lower_bound(p_dc_sw_[arc], flow_lb[l])
            end
            if !isinf(flow_ub[l])
                JuMP.set_upper_bound(p_dc_sw_[arc], flow_ub[l])
            end
        end
    end
    
    # this explicit type erasure is necessary
    p_dc_sw_expr = Dict{Any,Any}( (l,i,j) => p_dc_sw_[(l,i,j)] for (l,i,j) in _PM.ref(pm, nw, :arcs_from_sw_dc) )
    p_dc_sw_expr = merge(p_dc_sw_expr, Dict( (l,j,i) => -1.0*p_dc_sw_[(l,i,j)] for (l,i,j) in _PM.ref(pm, nw, :arcs_from_sw_dc)))
    _PM.var(pm, nw)[:p_dc_sw] = p_dc_sw_expr
    
    report && _PM.sol_component_value_edge(pm, nw, :dcswitch, :p_dc_sw_fr, :p_dc_sw_to, _PM.ref(pm, nw, :arcs_from_sw_dc), _PM.ref(pm, nw, :arcs_to_sw_dc), p_dc_sw_expr)
end
