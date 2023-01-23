#macro VUELTA_DEBUG true    // Permite mostrar mensajes
#macro VUELTA_ACTIVE global.__vueltaActive

/// @ignore
global.__vueltaActive = noone;

// -- Parent
/// @desc Function Description
function Vuelta() constructor 
{
	/// @ignore Variables que todos los elementos vuelta pueden usar y modificar
	static vars = {}
	/// @ignore
	is    = instanceof(self);
	/// @ignore
	name  = "";
	/// @ignore
	ready = false;
	/// @ignore
	started = false;	
	
	/// @ignore
	timeScale = 1;
	/// @ignore
	manager = weak_ref_create(vars);
	
	#region METHODS
	#region Global
	/// @func setVariable(key, value)
	/// @param {string} key
	/// @param {string} value
	static setVariable = function(_key, _value)
	{
		vars[$ _key] = _value;
		return self;
	};
	
	/// @func getVariable(key)
	/// @param {string} key
	static getVariable = function(_key)
	{
		return (vars[$ _key] );
	};
	
	/// @param {string} key
	static existsVariable = function(_key)
	{
		return (variable_struct_exists(vars, _key) );
	};

	/// @func removeVariable(key)
	/// @param {string} key
	static removeVariable = function(_key)
	{
		var _value = vars[$ _key];
		variable_struct_remove(vars, _key);
		return (_value);
	};

	/// @desc Busca datos en las variables puede buscar entre structs separando palabras mediante "."
	/// @param {string} variableName
	static findInVars = function(_str)
	{
		var _instance, _num = string_count(".", _str);
		
		// Buscar en grupos
		if (_num > 0) {
			var _split = string_split(_str, "."); // Obtener array
			// Entrar en el primer grupo
			var _key = _split[0];
			var _ins = vars[$ _key], _inside;
			var i=1; repeat(array_length(_split) - 1) {
				_key    = _split[i];
				_inside = _ins;
				// Entrar en los grupos hasta llegar al final1
				_ins = _inside[$ _key];
				i++;
			}
			// Guardar final
			_instance = _ins;
		} 
		// Busqueda directa
		else { 
			_instance = vars[$ _str];
		}
		
		return (_instance);
	}

	#endregion
	
	/// @ignore
	/// @return {bool}
	static in  = function() {return true;}
	
	/// @ignore
	/// @return {bool}
	static out = function() {return true;}
	
	/// @desc Cambia la escala de tiempo
	/// @param {real} [timeScale]=1
	static setTimeScale = function(_timeScale=1)
	{
		timeScale = _timeScale;
		return self;
	}
	
	/// @desc Cambia el nombre de esta Vuelta
	/// @param {string} name Description
	static setName = function(_name)
	{
		name = _name;
		return self;
	}
	
	/// @param {Struct.VueltaManager} VueltaManager
	static setManager = function(_vtm) 
	{
		manager = weak_ref_create(_vtm);
		return self;
	}
	
	/// @desc Devuelve el VueltaManager que lo maneja
	/// @return {Struct.VueltaManager}
	static getManager = function()
	{
		return (manager.ref);
	}
	
	/// @desc Devolver si esta listo
	/// @return {bool}
	static isReady = function() 
	{
		return (ready);
	}
	
	/// @ignore
	/// @return {bool}
	static event = function () 
	{
		return ready; 
	}
	
	/// @desc Funcion a ejecutar cuando inicia el vuelta
	/// @ignore
	funStart = function() {}
	/// @param {function} funStart
	static setFunStart = function(_fun) 
	{
		funStart = _fun;
		return self;
	}
	
	/// @desc Funcion a ejecutar cuando termina el Vuelta
	/// @ignore
	funEnd = function() {}
	/// @param {function} funEnd
	static setFunEnd = function(_fun)
	{
		funEnd = _fun;
		return self;
	}
	
	/// @desc Funcion a ejecutar entre eventos
	/// @ignore
	funBetween = function() {}
	/// @param {function} funBetween
	static setFunBetween = function(_fun) 
	{
		funBetween = _fun;
		return self;
	}
	
	#endregion
}

/// @ignore
/// "Vuelta" es un sistema basado en lo creado por FriendlyCosmonaut pero utilizando funciones modernas de gml.
/// Permite ejecutar "eventos" secuenciados uno tras el otro. Las Vueltas se deben de iniciar utilizando el metodo .start() o usando vuelta_start
/// @param {string}               vueltaName  Nombre de este VueltaManager
/// @param {array<Struct.Vuelta>} events      Array de eventos
/// @param {bool}                 [seconds]   =true usar segundos(true) o steps(false)
/// @param {real}                 [timeScale] =1 Dilatacion de tiempo
function VueltaManager(_name, _events, _useSeconds=true, _timeScale=1) : Vuelta() constructor 
{
	if (!is_array(_events) ) {show_error("VueltaSystem: no se pasaron eventos a un manager", true); }
	/// @ignore Colocar nombre
	name = _name;
	
	/// @ignore Lista de eventos
	events = _events;
	/// @ignore Indice de eventos
	index  = 0;
	
	/// @ignore Funciones a ejecutar entre frames o segundos
	eventsStep = [];
	/// @ignore
	readyStep  = false;
	/// @ignore
	indexStep  = 0;
	/// @ignore
	isWorking = false; // Si esta procesando algun evento
	
	/// @ignore
	timeScale  = _timeScale ;
	/// @ignore
	useSeconds = _useSeconds;
	/// @ignore Cuantos steps (frames) han transcurrido
	stepCount  = 0;

	// Feather disable once GM1043
	/// @ignore
	step = time_source_create(time_source_game, 1, time_source_units_frames, method(self, update), [], -1);
	
	#region Revisar los eventos
	if (array_length(_events) > 0) {
		// Comprobar que donde se crea no sea otro VueltaManager
		// Feather disable once GM1009
		if (variable_struct_exists(other, "is") ) {
			var _check = other.is;
			// Feather disable once GM1019
			// Iniciar time-source
			start((_check != "VueltaManager") ); 
		}
		
		// Comprobar cada evento
		array_foreach(events, function(v,i) {
			// Pasar un array a un VueltaManager
			var _this = self;
			var _name = string("{0} [{1}]", name, i);
			if (is_array(v) ) {
				var _vt = new VueltaManager(_name, v, useSeconds, timeScale);
				time_source_stop(_vt.step);
				_vt.setManager(_this);
			} 
			else {
				// poner el mismo nombre
				v.setName(_name);
				v.setTimeScale(timeScale, useSeconds);
				v.setManager(_this);
			}
		});
	}
	
	#endregion
	
	#region METHODS
	/// @ignore
	/// @desc Function Description
	/// @param {real}       step  Description
	/// @param {function}   event Description
	static VueltaStep = function(_step, _event) constructor 
	{
		step  = _step;
		event = method(other, _event); 
	}
	
	/// @ignore
	static update = function() 
	{
		var n;
		// Contar steps
		stepCount++;
		
		#region -- Procesar steps
		if (array_length(eventsStep) > 0) {
			if (!readyStep) {
				var _step = eventsStep[indexStep];
				if (_step.step == stepCount) {
					_step.event();
					indexStep++;
					readyStep = (++indexStep >= array_length(eventsStep) );
				}
			}
		}
		#endregion
		
		#region -- Procesar eventos
		var _event = events[index], _eventReady = false;
		with (_event) {
			if (!started) {
				method(self, funStart) ();
				start(true);
			}
			// Ejecutar delay de entrada
			if (in() ) {
				// Ejecutar evento y comprobar si se paso el delay de parada
				_eventReady = event();
				// Debug
				if (!is_undefined(message ) ) {
					show_message(message);
					message = undefined;
				}
			}
		}
		
		if (_eventReady) {
			// Funcion final del EVENTO
			method(self, _event.funEnd) ();
			// Aumentar indice
			n=array_length(events);
			index = index + 1;
			
			// Completo los eventos que posee
			if (index >= n) {
				ready = true;
				isWorking = false;          // Termino de trabajar
				time_source_destroy(step);  // Destruir time-source
				// Llamar funcion final
				funEnd();
				gc_collect() // Llamar al GarbageCollector
				
				if (VUELTA_DEBUG) {
					show_debug_message("VueltaSystem {0}: No más eventos", name); 
				}
			} 
			// Llamar funcion entre eventos
			else {
				funBetween(); 
			}
		} 
		else {
			isWorking = true;
		}
		
		#endregion
	}

	/// @desc Cambia el indice de evento actual
	static setIndex = function(_index) 
	{
		indexStep = _index;
		return self;
	}

	/// @desc Inicia la ejecucion de este vuelta
	static start  = function(_check=true)
	{		
		if (_check) {
			time_source_start(step);
			started = true;
		}
		
		return self;
	}
	
	/// @desc Pausa la vuelta
	static pause  = function()
	{
		time_source_pause(step);
		return self;
	}
	
	/// @desc Resume el time_source
	static resume  = function()
	{
		time_source_resume(step);
		return self;
	}
	
	/// @desc Destruye este vuelta
	static destroy = function() 
	{
		time_source_destroy(step);
		funEnd();
		// Llamar al GC
		gc_collect();
	}
	
	/// @param {real}       step  Description
	/// @param {function}   event Description
	static addFrameEvent = function(_step, _event)
	{
		array_push(eventsStep, new VueltaFrame(_step, _event) );
		array_sort(eventsStep, function(a,b) {
			return (a.step - b.step);
		} );
		return self;
	}
	
	#endregion
}


/// @param {real} [delayIn]  =0 delay de entrada
/// @param {real} [delayOut] =0 delay de salida
function VueltaEvent(_in=0, _out=0) : Vuelta() constructor
{
	/// @ignore
	message = undefined;
	/// @ignore
	inVal =  _in;
	/// @ignore
	ouVal = _out;
	
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
		if (inVal > 0) {
			inVal = inVal - 1;
			if (VUELTA_DEBUG) {
				show_debug_message("VueltaSystem ({0}): In Delay {1}", is, inVal);
			}
			return false;
		}
		
		return true;
	}
	
	/// @ignore
	/// @desc Procesar delay de salida. true: delay completado, false: delay incompleto
	/// @return {bool} 
	static out = function()
	{
		if (ouVal > 0) {
			ouVal = ouVal - 1;
			if (VUELTA_DEBUG) {
				show_debug_message("VueltaSystem ({0}): Out Delay {1}", is, ouVal);
			}
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

	/// @param {real} delayIn  delay de entrada
	/// @param {real} delayOut delay de salida
	static setDelay = function(_in, _out)
	{
		inVal =  _in ?? inVal;
		ouVal = _out ?? ouVal;
		return self;
	}

	/// @desc Mostrar un mensage cuando el manager va a usarlo
	/// @param {string} message mensaje a mostrar
	static debugShow = function(_msg) 
	{
		message = _msg;
		return self;
	}	
}


/// @param {real}                [delayIn]  =0 delay de entrada
/// @param {real}                [delayOut] =0 delay de salida
function VueltaPause(_in=0, _out=0) : Vuelta() constructor
{
	/// @ignore
	message = undefined;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function() 
	{
		if (!ready) {
			// Pausar VueltaManager
			var _vtm = getManager();
			_vtm.pause();
			
			ready = true;
		} else return (out() );
	}

	/// @ignore
	static start = function() 
	{
		started = true;
	}
}


/// @desc Ejecuta un metodo 1 vez. Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
/// @param {function}            method     metodo a usar
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {real}                [delayIn]  =0 delay de entrada
/// @param {real}                [delayOut] =0 delay de salida
function VueltaMethod(_fun, _args, _scope, _in=0, _out=0) : VueltaEvent(_in, _out) constructor 
{
	// Feather disable once GM1063
	/// @ignore
	fun = (is_method(_fun) ) ? method_get_index(_fun) : _fun;
	
	/// @ignore argumentos argumentos a pasar al metodo
	args  = _args ?? [];
	/// @ignore
	scope = _scope;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (scope) {
				script_execute_ext(_this.fun, _this.args);
			}
			ready = true;
			if (VUELTA_DEBUG) {show_debug_message("VueltaSystem (MethodEvent): Ready"); }
			return false;
		} else {
			return (out() );
		}
	}

	/// @ignore
	static start = function()
	{
		if (scope == undefined) {
			// Buscar en las variables
			if (is_string(scope) ) {
				var _str = scope;
				scope = findInVars(_str);
			}
			// El Manager es el scope default
			else {
				scope = getManager();
				if (VUELTA_DEBUG) {
					show_debug_message("VueltaSystem (LoopEvent): Target es el manager"); 
				}
			}
		}
		
		started = true;
	}
	
	/// @param {Array} argumentos
	static setArgs  = function(_args)
	{
		args = _args;
		return self;
	}
	
	/// @param {Id.instance or Struct} scope
	static setScope = function(_scope)
	{
		scope = _scope;
		return self;
	}
	
}


/// @desc Ejecuta un metodo hasta devolver "true". Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
/// @param {function}            method     metodo a usar
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {real}                [delayIn]  =0 delay de entrada
/// @param {real}                [delayOut] =0 delay de salida
function VueltaLoop(_fun, _args, _scope, _in, _out) : VueltaMethod(_fun, _args, _scope, _in, _out) constructor 
{
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (scope) {
				var _t = script_execute_ext(_this.fun, _this.args);
				_this.ready = _t;
			}
			if (VUELTA_DEBUG) {
				if (ready) show_debug_message("VueltaSystem (LoopEvent): Ready");
			}
			return false;
		} 
		else {
			return (out() );
		}
	}
}


/// @desc Ejecuta un metodo hasta que se cumple cierta condicion. Puede cambiar el scope en donde se ejecuta la funcion
/// @param {function}            method     Method que se ejecuta hasta cumplir la condicion
/// @param {function}            until      Condicion para avanzar
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {real}                [delayIn]  =0 delay de entrada
/// @param {real}                [delayOut] =0 delay de salida
function VueltaUntil(_fun, _until, _scope, _arg, _in, _out) : VueltaMethod(_fun, _arg, _scope, _in, _out) constructor 
{
	/// @ignore
	unt = (is_method(_until) ) ? method_get_index(_until) : _until;

	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (scope) {
				script_execute(_this.fun);
				// Comprobar si se cumple la condicion para avanzar
				_this.ready = script_execute(_this.unt);
			}
			if (VUELTA_DEBUG) {if (ready) show_debug_message("VueltaSystem (MethodEvent): Ready"); }
			return false;
		} 
		else {
			return (out() );
		}
	}
}


/// @desc Ejecuta un metodo 1 vez y luego revisa si puede avanzar o no. Puede cambiar el scope en donde se ejecuta la funcion
/// @param {function}            method     Method que se ejecuta 1 vez
/// @param {function}            until      Condicion para avanzar
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {real}                [delayIn]  =0 delay de entrada
/// @param {real}                [delayOut] =0 delay de salida
function VueltaDo(_fun, _until, _scope, _arg, _in, _out) : VueltaUntil(_fun, _until, _scope, _arg, _in, _out) constructor 
{
	/// @ignore
	first = false;
	
	/// @ignore
	/// @desc Evento a ejecutar	
	static event = function()
	{
		if (!ready) {
			var _this = self;
			if (!first) {
				with (scope) {script_execute(_this.fun); }
				first = true;
			} else {
				with (scope) {
					_this.ready = script_execute(_this.unt); 
				}
			}
			
			if (VUELTA_DEBUG) {if (ready) show_debug_message("VueltaSystem (MethodEvent): Ready"); }
			return false;
		} else {
			return (out() );
		}
	}
}


/// @desc Function Description
/// @param {Array<Struct.VueltaEvent>} events       Array de VueltaEvents
/// @param {real}                      [delayIn] =0 Delay de entrada
/// @param {real}                      [delayOut]=0 Delay de salida
function VueltaPack(_events, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	events = _events; 
	/// @ignore
	size  = array_length(events);
	/// @ignore
	index  = 0;
	/// @ignore
	direct = undefined; 
	
	/// @ignore
	/// @desc Evento a ejecutar	
	static event = function()
	{
		var _e = events;
		var _n = size;
		with (direct) {
			for (var i=0; i<_n; i++) {
				var _ve = _e[i];
				if (!_ve.started) {
					_ve.start(true);
					// Funcion inicial del evento
					method(self, funStart) (true);
				}
				var _rd = _ve.event();
				// Eliminar para no ejecutar de nuevo
				if (_rd) {
					// Ejecutar funcion final del evento
					method(self, _ve.funEnd) ();
					array_delete(_e, i, 1);
					_n--;
				}
			}
		}
		size = _n;
		return (size <= 0);
	}
	
	/// @ignore
	static start = function()
	{
		size    = array_length(events);
		direct  = getManager();
		started = true;

		var i=0; repeat(size) {
			var _vt  = events[i];
			var _str = string(name + " pack[{0}]", i);
			_vt.setName(_str);
			_vt.setManager(direct);
			i++
		}
	}
}

#region Eventos de instancias

/// @desc Mueva una instancia hacia un objetivo
/// @param {Id.instance, Asset.GMObject} instances  Puede ser un objeto o una instancia string para una instancia guardada en una variable
/// @param {real}                        speed              Velocidad a la que se mueve
/// @param {Struct}                      positionX          posicion x a la que moverse
/// @param {Struct}                      positionY          posicion y a la que moverse
/// @param {bool}                        [relative] =false  moverse relativo a su posicion
/// @param {real}                        [delayIn]  =0      delay de entrada
/// @param {real}                        [delayOut] =0      delay de salida
function VueltaMove(_ins, _speed, _posX, _posY, _rel=false, _in, _out) : VueltaEvent(_in, _out) constructor
{
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
	funMiddle = function() {}
	/// @ignore 
	distance  = 0;
	/// @ignore 
	distancePercent = 0.5;
	
	/// @ignore
	/// @desc Evento a ejecutar	
	static event = function()
	{
		if (!ready) {
			if (VUELTA_DEBUG) {
				if (!instance_exists(target) ) show_debug_message("VueltaSystem: Target == No exists"); 	
			}
			
			var _x, _y;
			if (relative) {
				_x = target.x + positionX;
				_y = target.y + positionY;
				
				positionX = _x;
				positionY = _y;
				// No calcular nuevamente la posicion
				relative  = false;
				// Obtener distancia total
				distance = point_distance(target.x, target.y, _x, _y);
			} 
			else {
				var _xp = positionX, _yp = positionY;
				if (is_method(_xp) ) {_x = _xp(); } else {_x = positionX; }
				if (is_method(_yp) ) {_y = _yp(); } else {_y = positionY; }
			}
			
			var _this = self;
			var _spd  = speed; 
			var _dist = 0;
			with (target) {
				_dist = point_distance(x, y, _x, _y)
				// Ir hacia el punto
				if (_dist >= _spd) { 
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
			// Evento al llegar al medio
			var _distPcr = round(distance*distancePercent);
			//show_debug_message("pcr: {0} dis: {1}", _distPcr, _dist);
			if (_dist == _distPcr) {
				funMiddle();
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
		// Si el target es una variable del VueltaGlobal
		if (is_string(target) ) {
			var _ins = findInVars(target);
			if (_ins != undefined) target = _ins;
		}
		
		var _x = positionX, _y = positionY;
		// -- X
		if (is_string(_x) ) {positionX = (parserPos(_x) ) ?? target.x; }
		// -- Y
		if (is_string(_y) ) {positionY = (parserPos(_y) ) ?? target.y; }
		
		// Obtener distancia total
		distance = point_distance(target.x, target.y, positionX, positionY);
		
		started = true;
	}
	
	/// @ignore
	static setMiddle = function(_fun, _percent=.5)
	{
		funMiddle = _fun;
		distancePercent = _percent;
		return self;
	}
	
	/// @ignore
	static parserPos = function(_str) 
	{
		// Ver si posee .
		var _dots = string_count(".", _str);
		if (_dots > 0) {
			var _split = string_split(_str, "."); // Obtener array
			// Entrar en el primer grupo
			var _key = _split[0];
			var _ins = vars[$ _key], _inside;
			var i=1; repeat(array_length(_split) - 1) {
				_key    = _split[i];
				_inside = _ins;
				// Entrar en los grupos hasta llegar al final1
				_ins = _inside[$ _key];
				i++;
			}
			
			return _ins;
		} else {
			if (variable_struct_exists(vars, _str) ) {
				return (vars[$ _str] );
			} else {
				return undefined;
			}
		}
	}
}

/// @desc Cambia el sprite de una instancia
/// @param {Id.instance or Asset.GMObject} instance     instancia a usar (puede ser un objeto)
/// @param {Asset.GMSprite}                spriteIndex  
/// @param {real}                          imageIndex   
/// @param {real}                          imageSpeed   
/// @param {real}                          [delayIn]    =0 delay de entrada
/// @param {real}                          [delayOut]   =0 delay de salida
function VueltaSprite(_ins, _sprite, _imgIndex=0, _imgSpeed=0, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore objetivo
	target = _ins;
	/// @ignore sprite a usar
	sprite = _sprite;
	/// @ignore image index
	imgIndex = _imgIndex;
	/// @ignore imagen speed
	imgSpeed = _imgSpeed;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _this = self;
			with (target) {
				if (_this.sprite != undefined) sprite_index = _this.sprite;
				
				image_index = _this.imgIndex;
				image_speed = _this.imgSpeed;
			}
			
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
			var _ins = findInVars(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}	
}

#endregion


#region Eventos de assets




#endregion