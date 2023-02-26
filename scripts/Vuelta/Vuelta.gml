#macro __VUELTA_VERSION    "v1.0"
#macro __VUELTA_DEBUG      true        // Permite mostrar mensajes
#macro __VUELTA_SHOW_DELAY false

show_debug_message("Vuelta! {0} te da la bienvenida", __VUELTA_VERSION);

/// @desc Padres de todos
/// @ignore
function Vuelta() constructor 
{
	// Variables que todos los elementos vuelta pueden usar y modificar
	static vars = {}
	
	/// @ignore
	is = instanceof(self);
	/// @ignore
	name  = "";
	/// @ignore Para buscar este Evento
	id    = "";
	/// @ignore
	message = undefined;

	/// @ignore
	ready = false;
	/// @ignore
	started = false;
	
	/// @ignore
	timeScale = 1;
	/// @ignore
	manager = weak_ref_create(vars);

	/// @ignore
	/// @desc Funcion a ejecutar cuando inicia el vuelta
	fnStart = function() {}
	
	/// @ignore
	/// @desc Funcion a ejecutar cuando termina el Vuelta
	fnEnd = function() {}

	/// @ignore
	/// @desc Funcion al cambiar de evento
	fnChange = function() {}

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
	/// @param  {string} variableName
	/// @return {any*}
	static searchVariable = function(_str)
	{
		var _dots = string_count(".", _str);
		
		// Buscar en grupos
		if (_dots > 0) {
			var _split = string_split(_str, "."); // Obtener array
			
			// Entrar en el primer grupo
			var _key = _split[0], _var1;
			var _var2 = vars[$ _key];
			var i=1; repeat(array_length(_split) - 1) {
				_key  = _split[i++];
				_var1 = _var2;
				// Entrar en los grupos hasta llegar al final1
				_var2 = _var1[$ _key];
			}
			
			return (_var2);
		} 
		
		return (vars[$ _str] );
	}

	#endregion
	
	/// @return {bool}
	static in  = function() {return true;}
	
	/// @return {bool}
	static out = function() {return true;}
	
	/// @desc Cambia la escala de tiempo
	/// @param {real} [timeScale]=1
	/// @return {self}
	static setTimeScale = function(_timeScale=1)
	{
		timeScale = _timeScale;
		return self;
	}
	
	/// @desc Cambia el nombre de esta Vuelta
	/// @param {string} name Description
	/// @return {self}
	static setName = function(_name)
	{
		name = _name;
		return self;
	}
	
	/// @param {Struct.VueltaManager} VueltaManager
	/// @return {self}
	static setManager = function(_vtm) 
	{
		manager = weak_ref_create(_vtm);
		return self;
	}
	
	/// @desc Devuelve el VueltaManager que lo maneja
	/// @return {Struct.VueltaManager}
	/// @return {self}
	static getManager = function()
	{
		return (manager.ref);
	}
	
	/// @desc Devolver si esta listo
	/// @return {bool}
	/// @return {self}
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

	/// @param {function} endFunction
	/// @return {self}
	static setFnEnd  = function(_fn) 
	{
		fnEnd = _fn;
		return self;
	}
	
	/// @param {function} startFunction
	/// @return {self}
	static setFnStart = function(_fn)
	{
		fnStart = _fn;
		return self;
	}
	
	/// @param {function} changeFunction
	/// @return {self}
	static setFnChange = function(_fn)
	{
		fnChange = _fn;
		return self;
	}

	/// @desc Function Description
	/// @param {string} message mensaje a mostrar
	/// @return {self}
	static debugShow = function(_msg) 
	{
		message = _msg;
		return self;
	}

	#endregion
}

/** @desc  
    Vuelta! es un sistema que permite ejecutar "eventos" secuenciados uno tras el otro. 
    Las Vueltas se deben de iniciar utilizando el metodo .start() o usando vuelta_start
*/
/// @param {string}               vueltaName  Nombre de este VueltaManager
/// @param {array<Struct.Vuelta>} events      Array de eventos
/// @param {bool}                 [seconds]   =true usar segundos(true) o frames(false)
/// @param {real}                 [timeScale] =1 Dilatacion de tiempo
/// @ignore
function VueltaManager(_name, _events, _useSeconds=true, _timeScale=1) : Vuelta() constructor 
{
	if (!is_array(_events) ) {show_error("VueltaSystem: no se pasaron eventos a un manager", true); }
	/// @ignore Colocar nombre
	name = _name;
	/// @ignore
	is = instanceof(self);
	
	/// @ignore Lista de eventos
	events = _events;
	/// @ignore Indice de eventos
	index  = 0;
	
	/// @ignore Funciones a ejecutar entre frames o segundos
	eventsFrame = [];
	/// @ignore
	readyFrame  = false;
	/// @ignore
	indexFrame  = 0;
	
	/// @ignore
	isWorking = false; // Si esta procesando algun evento
	
	/// @ignore
	timeScale  = _timeScale ;
	/// @ignore
	useSeconds = _useSeconds;
	/// @ignore Cuantos frames han transcurrido
	frameCount  = 0;
	
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
	
	#region Methods
	/// @ignore
	/// @desc Function Description
	/// @param {real}       frame Description
	/// @param {function}   event Description
	static VueltaFrame = function(_frame, _event) constructor 
	{
		frame = _frame;
		event = method(other, _event); 
	}
	
	/// @ignore
	static update = function() 
	{
		var n;
		// Contar frames
		frameCount++;
		
		#region -- Procesar steps
		if (array_length(eventsFrame) > 0) {
			if (!readyFrame) {
				var _frame = eventsFrame[indexFrame];
				if (_frame.frame == frameCount) {
					_frame.event();
					readyFrame = (frameCount + 1 >= array_length(eventsFrame) );
				}
			}
		}
		#endregion
		
		#region -- Procesar eventos
		var _event = events[index], _eventReady = false;
		var _this  = self;
		with (_event) {
			if (!started) {
				method(_this, fnStart) ();
				start(true);
				// Marcar que ya se inció
				started = true;
			}
			// Ejecutar delay de entrada
			if (in() ) {
				// Ejecutar evento y comprobar si se paso el delay de parada
				_eventReady = event();
				// Debug message
				if (!is_undefined(message ) ) {show_message(message); message = undefined; }
			}
		}
		
		if (_eventReady) {
			// Funcion final del EVENTO
			method(_this, _event.fnEnd) ();
			//
			n = array_length(events);
			index = index + 1;
			
			// Completo los eventos que posee
			if (index >= n) {
				ready = true;
				// Termino de trabajar
				isWorking = false;
				// Destruir time-source
				time_source_destroy(step);
				
				fnEnd();
				
				// Llamar al Garbage collector
				gc_collect();
				
				if (__VUELTA_DEBUG) vuelta_trace(string("{0} No más eventos", name) );
			} 
			// Llamar funcion al cambiar de eventos
			else {
				method(_this, _event.fnChange) ();
				fnChange(); 
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
		index = clamp(_index, 0, array_length(events) - 1);
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
		fnEnd();
		
		// Llamar al GC
		gc_collect();
	}
	
	/// @param {real}       frame Description
	/// @param {function}   event Description
	static addFrameEvent = function(_frame, _event)
	{
		array_push(eventsFrame, new VueltaFrame(_frame, _event) );
		array_sort(eventsFrame, function(a,b) {return (a.frame - b.frame); } );
		return self;
	}
	
	/// @ignore
	static replay = function()
	{
		array_foreach(events, function(v, i) {
			var _in = v.inRep;
			var _ou = v.ouRep;
			
			v.inVal = (is_array(_in) ) ? _in[irandom(array_length(_in) - 1) ] : _in;
			v.ouVal = (is_array(_ou) ) ? _ou[irandom(array_length(_ou) - 1) ] : _ou;
			// Establecer escala de tiempo
			v.setTimeScale(timeScale, useSeconds);
			
			v.ready = false;
		} );
		// Poner indice de evento en 0
		index = 0;
		frameCount = 0;
		
		return self;
	}
	
	#endregion
}


/** @desc De este constructor deben de heredar todos los VueltaEvent para evitar problemas
*/
/// @param {real|array<real>} [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>} [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaEvent(_in=0, _out=0) : Vuelta() constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore
	inVal =  _in;
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
		if (inVal > 0) {
			inVal = inVal - 1;
			if (__VUELTA_DEBUG) {
				if (__VUELTA_SHOW_DELAY) vuelta_trace(string("In Delay {0}"), inVal);
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
			if (__VUELTA_DEBUG) {
				if (__VUELTA_SHOW_DELAY) vuelta_trace(string("In Delay {0}"), ouVal);
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
	/// @return {self}
	static setDelay = function(_in, _ou)
	{
		inVal = _in ?? inVal;
		inRep = inVal;
		if (is_array(_in) ) inVal = _in[irandom(array_length( _in) - 1) ];
		/// @ignore
		ouVal = _ou ?? ouVal;
		ouRep = ouVal;
		if (is_array(_ou) ) ouVal = _ou[irandom(array_length(_ou) - 1) ];

		return self;
	}
}


/** @desc Detiene el VueltaManager
*/
/// @param {real|array<real>} [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>} [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaPause(_in=0, _out=0) : Vuelta() constructor
{
	/// @ignore
	is = instanceof(self);

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
/// @param {real|array<real>}    [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}    [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
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
	is = instanceof(self);
	
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
			// Mensaje cuando esta listo
			if (__VUELTA_DEBUG) vuelta_trace("Ready"); 
			
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
			if (__VUELTA_DEBUG) vuelta_trace("Target es el manager");
		}
		// Buscar en las variables
		else if (is_string(scope) ) {
			var _str = scope;
			scope = searchVariable(_str);
			if (__VUELTA_DEBUG) vuelta_trace(string("Target es {0}", _str));
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


/** @desc Ejecuta un metodo hasta que este devuelva "true", si devuelve true entonces avanza al siguiente metodo. 
          Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}            method     metodo a usar
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {real|array<real>}    [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}    [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaLoop(_fun, _args, _scope, _in, _out) : VueltaMethod(_fun, _args, _scope, _in, _out) constructor 
{
	/// @ignore
	is = instanceof(self);

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
			if (__VUELTA_DEBUG) {
				if (ready) vuelta_trace("Ready");
			}
			return false;
		} 
		else {
			return (out() );
		}
	}
}


/** @desc Ejecuta un metodo continuamente hasta que se cumple cierta condicion, cuando esta condicion se cumple avanza al siguiente evento. 
          Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}            method     Method que se ejecuta hasta cumplir la condicion
/// @param {function}            until      Condicion para avanzar
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {real|array<real>}    [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}    [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaUntil(_fun, _until, _scope, _arg, _in, _out) : VueltaMethod(_fun, _arg, _scope, _in, _out) constructor 
{
	/// @ignore
	is = instanceof(self);
	
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
			
			if (__VUELTA_DEBUG) {
				if (ready) vuelta_trace("Ready");
			}
			return false;
		} 
		else {
			return (out() );
		}
	}
}


/** @desc Ejecuta un metodo 1 vez y luego revisa si puede avanzar o no, si puede cambia al siguiente evento. 
          Puede utilizar los argumentos que se pasan y cambiar el scope en donde se ejecuta la funcion
*/
/// @param {function}            method     Method que se ejecuta 1 vez
/// @param {function}            until      Condicion para avanzar
/// @param {Struct|Id.Instance}  scope      En donde se ejecutara la función
/// @param {array}               argumentos argumentos a pasar al metodo
/// @param {real|array<real>}    [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}    [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaDo(_fun, _until, _scope, _arg, _in, _out) : VueltaUntil(_fun, _until, _scope, _arg, _in, _out) constructor 
{
	/// @ignore
	is = instanceof(self);
	
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
			
			if (__VUELTA_DEBUG) {
				if (ready) vuelta_trace("Ready");
			}
			return false;
		} else {
			return (out() );
		}
	}
}


/** @desc Ejecuta varios eventos al mismo tiempo. Cuando todos estos eventos son completados avanza al siguiente evento
*/
/// @param {Array<Struct.VueltaEvent>} events        Array de VueltaEvents
/// @param {real|array<real>}          [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}          [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaPack(_events, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
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
					// Funcion inicial del evento
					method(self, _ve.fnStart) (true);
					_ve.start(true);
					_ve.started = true;
				}
				
				var _rd = _ve.event();
				// Eliminar para no ejecutar de nuevo
				if (_rd) {
					// Ejecutar funcion final del evento
					method(self, _ve.fnEnd) ();
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
		direct  = getManager();
		size    = array_length(events);
		started = true;
		
		var i=0; repeat(size) {
			var _vt  = events[i];
			var _str = string(name + " pack[{0}]", i);
			_vt.setName(_str);      // Poner nombre
			_vt.setManager(direct); // Establecer cada event a quien controla a el pack
			i++
		}
	}
}


/** @desc Repite un vuelta una cantidad de veces (puede ser infinitamente). All llegar a 0 avanza al siguiente evento
*/
/// @param {real}             repeatTimes infinity para repetir para siempre. No puede ser menor o igual a 0
/// @param {real|array<real>} [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>} [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
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
				var _mn = getManager();
				with (_mn) {
					replay();
				}
				return false;
			}
			// Repetir las veces indicada
			else {
				times--;
				if (times > 1) {
					// Reiniciar vuelta
					with (getManager() ) replay();
				
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


#region Eventos de instancias

/** @desc Mueva una instancia hacia un objetivo al llegar a este objetivo entonces pasa el siguiente evento
*/
/// @param {Id.instance|Asset.GMObject} instances  Puede ser un objeto o una instancia string para una instancia guardada en una variable
/// @param {real}                       speed      Velocidad a la que se mueve
/// @param {Struct}                     positionX  Posicion x a la que moverse
/// @param {Struct}                     positionY  Posicion y a la que moverse
/// @param {bool}                       [relative] =false  Moverse relativo a su posicion
/// @param {real|array<real>}           [delayIn]  =0 Delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}           [delayOut] =0 Delay de salida . Si es un array selecciona uno de los valores de este
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
	
	/// @desc Funcion a ejecutar en un porcentaje
	/// @ignore
	fnPercent = function() {};
	/// @ignore
	distance  = 0;
	/// @ignore
	distancePercent = 0.5;
	
	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			if (__VUELTA_DEBUG && !instance_exists(target) ) vuelta_trace("Target == No exists");
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
			
			// Evento al llegar al medio
			var _percent = round(distance*distancePercent);
			
			if (__VUELTA_DEBUG) vuelta_trace(string("Move %: {0} Distance: {1}", _percent, _distance));
			if (_distance == _percent) method(manager, fnPercent) ();
			
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
			var _ins = searchVariable(target);
			if (_ins != undefined) target = _ins;
		}
		
		var _x = positionX, _y = positionY;
		// -- X
		if (is_string(_x) ) {positionX = (searchVariable(_x) ) ?? target.x; }
		// -- Y
		if (is_string(_y) ) {positionY = (searchVariable(_y) ) ?? target.y; }
		
		// Obtener distancia total
		distance = point_distance(target.x, target.y, positionX, positionY);
		manager  = getManager();
		started = true;
	}
	
	/// @desc Establece una funcion para este porcentaje de completado entre la instancia y la posicion del objetivo
	/// @param {function} percentFn funcion a ejecutar cuando se llege al % de completado
	/// @param {function} [percent] % de completado a ejecutar esta función default=0.5 
	static setPercentFn = function(_fun, _percent=.5)
	{
		fnPercent = _fun;
		distancePercent = _percent;
		return self;
	}
}

/** @desc @desc Cambia el sprite de una instancia
*/
/// @param {Id.instance|Asset.GMObject} instance     instancia a usar (puede ser un objeto)
/// @param {Asset.GMSprite}             spriteIndex
/// @param {real}                       imageIndex
/// @param {real}                       imageSpeed
/// @param {real|array<real>}           [delayIn]  =0 delay de entrada. Si es un array selecciona uno de los valores de este
/// @param {real|array<real>}           [delayOut] =0 delay de salida . Si es un array selecciona uno de los valores de este
function VueltaSprite(_ins, _sprite, _imgIndex=0, _imgSpeed=0, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
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
			var _ins = searchVariable(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}	
}

#endregion


#region Eventos de assets (Puedes borrar lo que no utilices)
	#region AESnip
/** @desc Cambia el frame de un AESnipPlayer de una instancia
*/
function VueltaAEFrame(_ins, _imgIndex, _in, _out) : VueltaEvent(_in, _out) constructor
{
	/// @ignore
	is = instanceof(self);
	
	/// @ignore objetivo
	target = _ins;
	/// @ignore image index
	imgIndex = _imgIndex;

	/// @ignore
	/// @desc Evento a ejecutar
	static event = function()
	{
		if (!ready) {
			var _index = imgIndex;
			with (target) sprites.goToFrame(_index);
			
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
			var _ins = searchVariable(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}
}

/** @desc Cambia el Snip de un AESnipPlayer de una instancia
*/
function VueltaAESnip(_ins, _snip, _speed, _index=0, _in, _out) : VueltaEvent(_in, _out) constructor
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
				var _snip = self[$ _snip]; // Buscar snip
				// Cambiar velocidad
				_snip.setSpeed(_speed);
				// Reproducir nuevo snip
				sprites.play(_snip)
				if (_index != 0) sprites.goToFrame(_index);
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
			var _ins = searchVariable(target);
			if (_ins != undefined) target = _ins;
		}

		started = true;
	}
}

#endregion

#endregion





