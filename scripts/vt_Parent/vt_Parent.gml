// Feather ignore all
/** @desc 
	De este constructor deben de heredar todos los VueltaEvent para evitar problemas
*/
/// @param {real|array<real>} [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>} [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaEvent(_in=0, _out=0) : Vuelta() constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore
	inVal = _in;
	if (is_array(_in) )  inVal = _in [irandom(array_length( _in) - 1) ];
	/// @ignore
	ouVal = _out;
	if (is_array(_out) ) ouVal = _out[irandom(array_length(_out) - 1) ];
	
	/// @ignore Regresar a este valor en cada repeticion 
	inRep =  _in;
	/// @ignore Regresar a este valor en cada repeticiona
	ouRep = _out;
	
	/// @ignore
	/// @desc  Establece el tiempo y escala
	/// @param {real} [timeScale]=1    tiempo escala
	/// @param {bool} [seconds]  =true usar segundos?
	/// @returns {struct} Description	
	static setTimeScale = function(_scale=1, _seconds=true)
	{
		timeScale = _scale;
		// Si usar segundos
		if (_seconds) {
			var _s = game_get_speed(gamespeed_fps)
			inVal *= _s;
			ouVal *= _s;
		}
		
		return self;
	}

	/// @ignore
	/// @desc Procesar delay de entrada. true: delay completado, false: delay incompleto
	/// @return {Bool} 
	static in  = function()
	{
		if (inVal-- > 0) {
			if (__VUELTA_DEBUG && __VUELTA_DEBUG_DELAY) {vt_trace($"In Delay {inVal}"); }
			return false;
		}
		
		return true;
	}
	
	/// @ignore
	/// @desc Procesar delay de salida. true: delay completado, false: delay incompleto
	/// @return {bool} 
	static out = function()
	{
		if (ouVal-- > 0) {
			if (__VUELTA_DEBUG && __VUELTA_DEBUG_DELAY) {vt_trace($"Out Delay {ouVal}"); }
			return false;
		}
		
		return true;
	}
	
	/// @ignore
	static start = function() 
	{
		started = true;
		return self;
	}

	/// @param {real} in  delay de entrada
	/// @param {real} out delay de salida
	static setDelay = function(_in, _ou)
	{
		// -- IN.
		inRep = inVal;
		// Si hay que obtener un valor al azar
		if (is_array(_in) ) {
			var _index = irandom(array_length( _in) - 1);
			_in = inRep[_index];
		}
		inVal = _in ?? inVal;
		
		// -- OUT.
		ouRep = ouVal;
		// Si hay que obtener un valor al azar
		if (is_array(_ou) ) {
			var _index = irandom(array_length(_ou) - 1);
			ouVal = ouRep[_index];
		}
		ouVal = _ou ?? ouVal;
		
		return self;
	}
		
	/// @param {real,array<real>} in  delay de entrada
	static setDIn = function(_in)
	{
		inRep = _in;
		if (is_array(_in) ) {
			var _index = irandom(array_length(_in) - 1);
			_in = inRep[_index];
		}
		inVal = _in;
		
		return self;
	}
	
	/// @param {real,array<real>} out delay de salida
	static setDOu = function(_ou) 
	{
		ouRep = _ou;
		if (is_array(_ou) ) {
			var _index = irandom(array_length(_ou) - 1);
			_ou = ouRep[_index];
		}
		ouVal = _ou;
		
		return self;
	}	
	
}

