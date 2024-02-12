// Feather ignore all

#region -- MANAGER
/// @desc Inicia un Manager.
/// @param {Struct.VueltaManager} manager
/// @return {Struct.VueltaManager}
function vt_start(_vtm)
{
	return (_vtm.start() );
}

/// @desc Destruye un Manager.
/// @param {Struct.VueltaManager} manager
function vt_destroy(_vtm)
{
	_vtm.destroy();
}

/// @param {Struct.VueltaManager} vueltaManager
/// @param {function}             end
/// @return {Struct.VueltaManager}
function vt_set_end_function(_vuelta, _fn)
{
	return (_vuelta.setFnEnd(_fn) );
}

/// @param {Struct.VueltaManager} vueltaManager
/// @param {function}             start
/// @return {Struct.VueltaManager}
function vt_set_start_function(_vuelta, _fn)
{
	return (_vuelta.setFnStart(_fn) );
}

/// @param {Struct.VueltaManager} vueltaManager
/// @param {function}             change
function vt_set_change_function(_vuelta, _fn)
{
	return (_vuelta.setFnChange(_fn) );
}

#endregion

#region -- VARIABLES
/// @desc Devuelve un struct con todas las variables de Vuelta!
function vt_vars() 
{
	static v = static_get(Vuelta);
	return (v.vars);
}

/// @desc Establece una variable global en el manager
/// @param {string} key
/// @param {string} value
function vt_vars_set(_key, _value)
{
	static v = static_get(Vuelta);
	v.vars[$ _key] = _value;
}

/// @param {string} key
function vt_vars_exists(_key)
{
	static v = static_get(Vuelta);
	return (struct_exists(v.vars, _key) );
}

/// @desc Obtiene una variable global en el manager
/// @param {string} key
function vt_vars_get(_key)
{
	static v = static_get(Vuelta);
	return (v.vars[$ _key] );
}

/// @desc Remueve una variable global en el manager
/// @param {string} key
function vt_vars_remove(_key)
{
	static v = static_get(Vuelta);
	struct_remove(v.vars, _key);
}

/// @desc Reinicia todas las variables del sistema de Vuelta!
function vt_vars_reset()
{
	static v = static_get(Vuelta);
	// Reiniciar todas las variables de vuelta
	v.vars = {};
	
	// Llamar al colector de basura un frame despúes.
	call_later(1, time_source_units_frames, gc_collect);
}

/// @desc Busca datos en las de Vuelta! Puede buscar entre structs separando palabras mediante "."
/// @param {string} key
function vt_vars_search(_key)
{
	static vt  = static_get(Vuelta);
	static Dot = ".";
	// Obtener numero de . en el string.
	var _vtvars = vt.vars;
	var _dots   = string_count(Dot, _key);
	// Buscar en grupos
	if (_dots > 0) {
		// Obtener un array seperando el string usando "."
		var _split = string_split(_key, Dot); 
		// Entrar en el primer grupo
		var _skey = _split[0];
		var _var1 = undefined, _var2 = struct_get(_vtvars, _skey);
		var i=1; repeat(array_length(_split) - 1) {
			_skey = _split[i++];
			_var1 = _var2;
			// Entrar en los grupos hasta llegar al final de la cadena de structs.
			if (is_struct(_var1) ) {_var2 = struct_get(_var1, _key); }
		}
		
		return (_var2);
	} 
	// Si no hay "." entonces solo devolver algun valor.
	return (struct_get(_vtvars, _key) );	
}

/// @desc Ejecuta una funcion en las variables de Vuelta!
/// @param {function} fn
function vt_vars_execute(_fn)
{
	static v = static_get(Vuelta);
	return (method(v.vars, _fn) () );
}

#endregion

#region -- MISQ
/// @ignore
/// @param {string} debug
function vt_trace(_msg)
{
	// VueltaSystem(VueltaEvent): some message
	show_debug_message($"VueltaSystem \n{is} {name}: {_msg}");
}

/// @ignore
/// @param {string} error
/// @param {string} longError
/// @param {string} [script]
/// @param {string} [line]
/// @param {array}  [stacktrace]
function vt_error(_msg, _long, _script, _line, _stacktrace)
{
	throw ({
		// 
		message:     $"VueltaSystem \n{_msg}",
		// Mostrar el VueltaEvent y un mensaje extra
		longMessage: $"{is}: {_long}",
		script:      _script     ?? _GMFUNCTION_,
		line:        _line       ?? _GMLINE_,
		stacktrace:  _stacktrace ?? debug_get_callstack(),
	});
}

#endregion