// Feather ignore all
/** @desc 
	Mueva una instancia hacia un objetivo al llegar a este objetivo entonces pasa el siguiente evento
*/
/// @param {Id.instance|Asset.GMObject} instances  Puede ser un objeto o una instancia string para una instancia guardada en una variable
/// @param {real}                       speed      Velocidad a la que se mueve
/// @param {Struct}                     positionX  Posicion x a la que moverse
/// @param {Struct}                     positionY  Posicion y a la que moverse
/// @param {bool}                       [relative] =false  Moverse relativo a su posicion
/// @param {real,array<real>} [din]     =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>} [dout]    =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaMove(_ins, _speed, _posX, _posY, _rel=false, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore objetivo a buscar
	target =   _ins;
	/// @ignore velocidad
	speed  = _speed;
	
	/// @ignore posX
	positionX = _posX;
	/// @ignore posY
	positionY = _posY
	/// @ignore relativo?
	relative  = _rel;
	
	/// @ignore
	distance  = 0;
	
	// @ignore
	percentageUse = false;
	/// @ignore
	percentage   =  0.5;
	/// @ignore
	/// @desc Funcion a ejecutar en un porcentaje
	percentageFn =  function() {};
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			if (__VUELTA_DEBUG && !instance_exists(target) ) {vt_trace("Target == No exists"); }
			var _x = positionX, _y = positionY;
			if (relative) {
				_x = target.x + positionX;
				_y = target.y + positionY;
				// 
				positionX = _x;
				positionY = _y;
				// No calcular nuevamente la posicion
				relative = false;
				// Obtener distancia total
				distance = point_distance(target.x, target.y, _x, _y);
			} 
			// Si alguno es un method.
			else {
				if (is_method(_x) ) {_x = _x(); }
				if (is_method(_y) ) {_y = _y(); }
			}
			
			var _this = self;
			var _spd  = speed, _distance = 0;
			with (target) {
				_distance = point_distance(x, y, _x, _y)
				// Ir hacia el punto
				if (_distance >= _spd) { 
					var _dir = point_direction(x, y, _x, _y);
					var _lx = lengthdir_x(_spd, _dir);
					var _ly = lengthdir_y(_spd, _dir);
					
					x = x + _lx;
					y = y + _ly;
					
					_this.ready = false;
				} 
				// Se completo el recorrido
				else {
					x = _x;
					y = _y;
					
					_this.ready = true;
				}
			}
			
			// Funcion de porcentaje (% del recorrido total)
			if (percentageUse) {
				// Redondear los valores de porcentajes.
				_distance =    round(_distance);
				var _percent = round(distance*percentage);
				
				if (__VUELTA_DEBUG) vt_trace($"Move %: {_percent} Distance: {_distance}");
				if (_distance == _percent) {
					method(manager, percentageFn) ();
					// Realizar la funcion solo 1 vez.
					percentageUse = false; 
				}
			}
			
			return false;
		} 
		else {
			return (out() );
		}
	}

	/// @ignore
	static start = function()
	{
		// Si el target es una variable.
		if (is_string(target) ) {
			var _ins = vt_vars_search(target);
			if (_ins != undefined) target = _ins;
		}
		// Obtener posicion.
		var _len;
		var _x = positionX, _y = positionY;
		
		// -- X
		if (is_string(_x) ) {
			_len = string_length(_x);
			if (_len == 0) {positionX = target.x; } else {positionX = vt_vars_search(_x); }
		}
		// Restablecer valor.
		_x = is_method(positionX) ? positionX() : positionX;
		
		// -- Y
		if (is_string(_y) ) {
			_len = string_length(_y);
			if (_len == 0) {positionY = target.y; } else {positionY = vt_vars_search(_y); }
		}
		// Restablecer valor.
		_y = is_method(positionY) ? positionY() : positionY;
		
		// Obtener distancia total.
		distance = point_distance(target.x, target.y, _x, _y);
		// Establecer manager.
		manager  = getManager();
		// Marcar como iniciado.
		started  = true;
	}
	
	/// @desc Establece una funcion para este porcentaje de completado entre la instancia y la posicion del objetivo
	/// @param {function} percentFn funcion a ejecutar cuando se llege al % de completado
	/// @param {real}     [percent] % de completado a ejecutar esta función default=0.5 
	static setPercentageFn = function(_fun, _percent=.5)
	{
		// Indicar que se usará el porcentaje de completado.
		percentageUse = true;
		//
		percentage =   _percent;
		percentageFn = _fun;
		
		return self;
	}
}

/** @desc 
	Mueva una instancia hacia un objetivo al llegar a este objetivo entonces pasa el siguiente evento
*/
/// @param {Id.instance|Asset.GMObject} instances  Puede ser un objeto o una instancia. String para una instancia guardada en Vuelta!
/// @param {real}             speed      Velocidad a la que se mueve
/// @param {Struct}           positionX  Posicion x a la que moverse
/// @param {Struct}           positionY  Posicion y a la que moverse
/// @param {bool}             [relative] =false  Moverse relativo a su posicion
/// @param {real,array<real>} [din]      =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real,array<real>} [dout]     =0 delay de salida . Si es un array selecciona uno de los valores de este
function vuelta_move(_ins, _speed, _x, _y, _relative, _in, _out)
{
	var _move = new VueltaMove(_ins, _speed, _x, _y, _relative, _in, _out)
	return (_move);
}
