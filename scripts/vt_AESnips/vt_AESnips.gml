// Feather ignore all
/** @desc 
	Cambia el Snip de un AESnipPlayer de una instancia
*/
/// @param {id.instance,asset.GMObject} instance
/// @param {String}                     snipName  
/// @param {Real}                       speed     velocidad de animacion
/// @param {Real}                       index     indice de la animacion. def 0
/// @param {Real}                       [din]     delay de entrada. def 0
/// @param {Real}                       [dout]    delay de salida. def 0
function VueltaAESnip(_ins, _snip, _speed, _index=0, _in=0, _out=0) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore objetivo
	target = _ins;
	/// @ignore snipe
	snip  = _snip;
	/// @ignore image speed
	speed = _speed;
	/// @ignore image index
	index = _index;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _snip  =  snip;
			var _speed = speed, _index = index;
			with (target) {
				/// @context {ncTer12x16}
				_snip = self[$ _snip]; // Buscar snip
				// Cambiar velocidad
				_snip.setSpeed(_speed);
				// Reproducir nuevo snip
				if (animations.current() != _snip) animations.play(_snip)
				animations.toFrame(_index);
			}
			
			ready = true;
			
			return false;
		} 
		else return (out() );
	}
	
	/// @ignore
	static start = function()
	{
		// Si el target es una variable del VueltaGlobal
		if (is_string(target) ) {
			var _ins = vt_vars_search(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}
}

/** @desc 
	Cambia el frame de un AESnipPlayer de una instancia
*/
/// @param {id.instance,asset.GMObject} instance
/// @param {String}                     snipName  
/// @param {Real}                       speed     velocidad de animacion
/// @param {Real}                       index     indice de la animacion. def 0
/// @param {Real}                       [din]     delay de entrada. def 0
/// @param {Real}                       [dout]    delay de salida. def 0
function vuelta_aesnip(_ins, _snip, _speed, _index=0, _in=0, _out=0)
{
	var _aesnip = vuelta_aesnip(_ins, _snip, _speed, _index, _in, _out);
	return (_aesnip);
}


/** @desc 
	Cambia el frame de un AESnipPlayer de una instancia
*/
/// @param {id.instance,asset.GMObject} instance
/// @param {Real}                       index     indice de la animacion. def 0
/// @param {Real}                       [din]     delay de entrada. def 0
/// @param {Real}                       [dout]    delay de salida. def 0
function VueltaAEFrame(_ins, _index, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore objetivo
	target = _ins;
	/// @ignore image index
	imgIndex = _index;

	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _index = imgIndex;
			with (target) animations.toFrame(_index);
			
			ready = true;
			
			return false;
		} else {
			return (out() );
		}
	}
	
	/// @ignore
	static start = function()
	{
		// Si el target es una variable del VueltaGlobal
		if (is_string(target) ) {
			var _ins = vt_vars_search(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}
}

/** @desc 
	Cambia el frame de un AESnipPlayer de una instancia
*/
/// @param {id.instance,asset.GMObject} instance
/// @param {Real}                       index     indice de la animacion. def 0
/// @param {Real}                       [din]     delay de entrada. def 0
/// @param {Real}                       [dout]    delay de salida. def 0
function vuelta_aeframe(_ins, _index, _in=0, _out=0)
{
	var _aeframe = vuelta_aeframe(_ins, _index, _in, _out);
	return (_aeframe);
}
