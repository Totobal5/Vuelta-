// Feather ignore all
/** @desc 
    Detiene la ejecucion del VueltaManager.
*/
/// @param {real,array<real>} [din]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>} [dout] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaPause(_in=0, _out=0) : VueltaEvent() constructor
{
	/// @ignore
	is = instanceof(self);

	/// @ignore
	/// @desc Evento a ejecutar
	static event = function() 
	{
		if (!ready) {
			// Pausar VueltaManager
			var _mng = getManager();
			if (!is_undefined(_mng) ) _mng.pause();
			// Marcar como listo.
			ready = true;
			
		} else return (out() );
	}
}

/// @param {real,array<real>} [din]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>} [dout] =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_pause(_in, _out) 
{
	var _pause = new VueltaPause(_in, _out);
	return (_pause);
}