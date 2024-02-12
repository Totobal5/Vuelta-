// Feather ignore all
/** @desc 
	Ejecuta un metodo hasta que este devuelva "true", si devuelve true entonces avanza al siguiente metodo. 
	Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}            method       Metodo a usar
/// @param {array,any}           [arguments]  argumentos a pasar al metodo
/// @param {Struct,Id.Instance}  [scope]      En donde se ejecutara la función
/// @param {real,array<real>}    [din]        =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>}    [dout]       =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaLoop(_fun, _args, _scope, _in, _out) : VueltaMethod(_fun, _args, _scope, _in, _out) constructor 
{
	/// @ignore
	is = instanceof(self);

	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self, _t;
			// Feather ignore GM1049
			with (scope) {
				if (is_array(_this.args) ) {
					_t = script_execute_ext(_this.fun, _this.args);
				}
				else {
					_t = script_execute(_this.fun, _this.args);
				}
			}
			// Establecer
			ready = _t;
			
			// Debug
			if (__VUELTA_DEBUG && ready) {vt_trace("Ready"); }
			return false;
		} 
		else return (out() );
	}
}

/** @desc 
	Ejecuta un metodo hasta que este devuelva "true", si devuelve true entonces avanza al siguiente metodo. 
	Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}            method       Metodo a usar
/// @param {array,any}           [arguments]  argumentos a pasar al metodo
/// @param {Struct,Id.Instance}  [scope]      En donde se ejecutara la función
/// @param {real,array<real>}    [din]        =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>}    [dout]       =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_loop(_function, _arguments, _scope, _in, _out)
{
	var _loop = new VueltaLoop(_function, _arguments, _scope, _in, _out);
	return (_loop);
}

/** @desc 
	Ejecuta un metodo hasta que este devuelva "true", si devuelve true entonces avanza al siguiente metodo.
	Es ejecutado en las variables de Vuelta!
*/
/// @param {function}            method       Metodo a usar
/// @param {real,array<real>}    [din]        =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>}    [dout]       =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_loop_v(_function, _in, _out)
{
	var _loop = new VueltaLoop(_function, "manager", "/", _in, _out)
	return (_loop);
}
