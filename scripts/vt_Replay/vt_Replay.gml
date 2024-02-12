// Feather ignore all
/** @desc 
	Repite un vuelta una cantidad de veces (puede ser infinitamente).
	All llegar a 0 avanza al siguiente evento
*/
/// @param {real}             iterations infinity para repetir para siempre. No puede ser menor o igual a 0
/// @param {real,array<real>} [din]      =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>} [dout]     =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaReplay(_times, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	/// @ignore
	times  = max(_times, 1);
	
	/// @ignore
	static event = function() 
	{
		if (!ready) {
			// Repetir infinitamente
			if (times == infinity) {
				var _mng = getManager();
				if (!is_undefined(_mng) ) {_mng.replay(); }
				
				return false;
			}
			// Repetir las veces indicada
			else {
				if (times-- > 1) {
					// Reiniciar vuelta
					var _mng = getManager();
					if (!is_undefined(_mng) ) {_mng.replay(); }
					
					return false;
				} else {
					return true; 
				}
			}
		}
		// Al siguiente
		else return (out() );
	}
}

/** @desc 
	Repite un vuelta una cantidad de veces (puede ser infinitamente).
	All llegar a 0 avanza al siguiente evento
*/
/// @param {real}             iterations infinity para repetir para siempre. No puede ser menor o igual a 0
/// @param {real|array<real>} [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>} [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_replay(_times, _in, _out)
{
	var _replay = new VueltaReplay(_times, _in, _out)
	return (_replay);
}
