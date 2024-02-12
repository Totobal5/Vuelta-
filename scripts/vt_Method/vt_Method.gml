// Feather ignore all
/** @desc 
	Ejecuta un metodo 1 vez. Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}                   method       Metodo a usar
/// @param {array,any}                  [arguments]  argumentos a pasar al metodo
/// @param {struct,id.instance,string}  [scope]      En donde se ejecutara la función
/// @param {real,array<real>}           [din]        =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>}           [dout]       =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaMethod(_fun, _args, _scope, _in=0, _out=0) : VueltaEvent(_in, _out) constructor 
{
	/// @ignore Cuando no se pasa argumentos usar un array default.
	static DArgs = [];
	
	/// @ignore
	fun = (is_method(_fun) ) ? method_get_index(_fun) : _fun;
	
	/// @ignore Argumentos pasar al metodo/funcion.
	args  = _args ?? DArgs;
	/// @ignore
	scope = _scope;
	
	/// @ignore
	is = instanceof(self);
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (scope) {
				if (is_array(_this.args) ) {
					script_execute_ext(_this.fun, _this.args);
				}
				else {
					script_execute(_this.fun, _this.args);
				}
			}
			// Marcar como completado.
			ready = true;
			// Mensaje cuando esta listo
			if (__VUELTA_DEBUG) vt_trace("Ready"); 
			
			return false;
		} else {
			return (out() );
		}
	}

	/// @ignore
	static start = function()
	{
		// El Manager es el scope default
		if (is_undefined(scope) ) {
			scope = getManager();
			if (__VUELTA_DEBUG) vt_trace("Target es el manager");
		}
		// Buscar en las variables
		else if (is_string(scope) ) {
			// Utilizar las variables como scope
			if (scope = "/") {
				scope = vars;
				if (__VUELTA_DEBUG) vt_trace("Target es vars");
			}
			else {
				var _str = scope;
				scope = vt_vars_search(_str);
				if (__VUELTA_DEBUG) vt_trace($"Target es {_str}");
			}
		}
		
		// Pasar al manager como argumento.
		if (args == "manager") {args = getManager(); }
		// Indicar que inicio.
		started = true;
	}
	
	/// @param {array} argumentos
	static setArgs  = function(_args)
	{
		args = _args;
		return self;
	}
	
	/// @param {id.instance, struct} scope
	static setScope = function(_scope)
	{
		scope = _scope;
		return self;
	}
}

/** @desc Ejecuta un metodo 1 vez. Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion.
*/
/// @param {function} function
/// @param {any}      [arguments]
/// @param {any}      [scope]
/// @param {real}     [inDelay]
/// @param {real}     [outDelay]
function vuelta_method(_function, _arguments, _scope, _in, _out)
{
	var _method = new VueltaMethod(_function, _arguments, _scope, _in, _out)
	return (_method);
}

/** @desc Ejecuta un metodo 1 vez. Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion.
          Es ejecutado en las variables de Vuelta!
*/
/// @param {function} function
/// @param {real}     [inDelay]
/// @param {real}     [outDelay]
function vuelta_method_v(_function, _in, _out)
{
	var _method = new VueltaMethod(_function, "manager", "/", _in, _out)
	return (_method);
}