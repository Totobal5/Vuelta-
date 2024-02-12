// Feather ignore all
/** @desc
	Vuelta! es un sistema que permite ejecutar "eventos" secuenciados uno tras el otro.
	Las Vueltas se deben de iniciar utilizando el metodo .start() o usando vt_start.
*/
/// @param {string}               name        Nombre de este VueltaManager
/// @param {array<Struct.Vuelta>} events      Array de eventos
/// @param {bool}                 [seconds]   =true usar segundos(true) o frames(false)
/// @param {real}                 [timeScale] =1 Dilatacion de tiempo
/// @ignore
function VueltaManager(_name, _events, _useSeconds=true, _timeScale=1) : Vuelta() constructor 
{
	/// @ignore Colocar nombre
	name = _name;
	/// @ignore
	is = instanceof(self);
	
	/// @ignore Lista de eventos
	events = _events ?? [];
	/// @ignore Indice de eventos
	index  = 0;
	
	/// @ignore Funciones a ejecutar entre frames o segundos
	eventsFrame = [];
	/// @ignore
	readyFrame  = false;
	/// @ignore
	indexFrame  = 0;
	
	/// @ignore Si esta procesando algun evento
	isWorking = false;
	
	/// @ignore
	timeScale  =  _timeScale;
	/// @ignore
	useSeconds = _useSeconds;
	/// @ignore Cuantos frames han transcurrido
	frameCount = 0;

	// Feather disable once GM1043
	/// @ignore
	step = time_source_create(time_source_game, 1, time_source_units_frames, method(self, __update), [], -1);
	// Revisar los eventos pasados.
	__start();
	
	#region METHODS

	/// @ignore
	static __update = function() 
	{
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
				// Funcion al iniciar un nuevo evento
				method(_this, fnStart) ();
				// Marcar que ya se inció el manager
				started = true;
				// Funcion de inicio del evento
				start(true);
			}
			// Ejecutar delay de entrada
			if (in() ) {
				// Ejecutar evento y comprobar si se paso el delay de parada
				_eventReady = event();
				// Debug message
				if (debugMessage != "") {show_message(debugMessage); debugMessage = "";}
			}
		}
		
		if (_eventReady) {
			// Funcion final del EVENTO
			method(_this, _event.fnEnd) ();
			// Aumentar indice
			index = index + 1;
			// Completo los eventos que posee
			if (index >= array_length(events) ) {
				// Destruir.
				destroy();
				if (__VUELTA_DEBUG) vt_trace("No más eventos");
				// No ejecutar más codigo.
				exit;
			}
			// Llamar funcion al cambiar de eventos
			else {
				// Funcion de cambiar del evento actual/terminado
				method(_this, _event.fnChange) ();
				// Funcion de cambiar del manager
				fnChange();
			}
		}
		
		// Indicar que el manager esta trabajando
		isWorking = true;
		
		#endregion
	}
	
	/// @ignore
	static __start  = function()
	{
		if (array_length(events) ) {
			// Comprobar que donde se crea no sea otro VueltaManager
			if (variable_struct_exists(other, "is") ) {
				var _check = other.is;
				// Iniciar el manager.
				start((_check != "VueltaManager") ); 
			}
			
			// Comprobar cada evento
			array_foreach(events, function(_event, i) {
				// Pasar un array a un VueltaManager
				var _name = $"{name} [{i}]";
				if (is_array(_event) ) {
					with (vuelta(_name, _event, useSeconds, timeScale) ) {
						stop();
						setManager(other);
					}
				}
				else {
					// poner el mismo nombre
					_event.setName(_name);
					_event.setTimeScale(timeScale, useSeconds);
					_event.setManager(self);
				}
			});		
		}
	}
	
	/// @ignore
	/// @param {real}       frame Frame en donde se va ejecutar el evento.
	/// @param {function}   event Evento a ejecutar.
	static __VueltaFrame = function(_frame, _event) constructor 
	{
		frame = _frame;
		event = method(other, _event); 
	}
	
	#region -- CONTROL (Funciones para controlar el manager)
	/// @desc Inicia la ejecucion de este vuelta
	static start  = function()
	{
		// Fue destruido o ya se completo.
		if (ready) {
			// Re-crear time-source
			step = time_source_create(time_source_game, 1, time_source_units_frames, method(self, __update), [], -1);
		}
		
		// Iniciar time-source
		time_source_start(step);
		// Marcar que se a iniciado.
		started = true;
		
		return self;
	}
	
	/// @desc Pausa el manager.
	static pause  = function()
	{
		time_source_pause(step);
		return self;
	}
	
	/// @desc Resume el manager.
	static resume = function()
	{
		time_source_resume(step);
		return self;
	}
	
	/// @desc Detiene el manager.
	static stop = function()
	{
		time_source_stop(step);
		return self;
	}
	
	/// @desc Destruye el manager.
	static destroy = function() 
	{
		// Marcar como listo.
		ready =     true;
		isWorking = false;
		// Indicar que no se ha iniciado.
		started =   false;
		
		// Destruir time-source y ejecutar función.
		time_source_destroy(step);
		if (!fnEndReady) method(self, fnEnd) ();
		
		// Llamar al GC
		call_later(1, time_source_units_frames, gc_collect);
	}

	/// @desc Cambia el indice de evento actual.
	/// @param {real} index
	static setIndex = function(_index) 
	{
		index = clamp(_index, 0, array_length(events) - 1);
		return self;
	}
	
	#endregion
	
	#region -- MISQ
	/// @desc Agrega un evento a el manager.
	/// @param {Struct.Vuelta} evento
	static addEvent = function(_event)
	{
		var _size = array_length(events);
		var _name = $"{name} [{_size}]";
		
		// Establecer valores.
		_event.setName(_name);
		_event.setTimeScale(timeScale, useSeconds);
		_event.setManager(self);
		
		// Añadir al array.
		array_push(events, _event);
		
		return self;
	}
	
	/// @desc Agrega un evento de frame al manager.
	/// @param {real}       frame Description
	/// @param {function}   event Description
	static addFrameEvent = function(_frame, _event)
	{
		array_push(eventsFrame, new __VueltaFrame(_frame, _event) );
		array_sort(eventsFrame, function(a,b) {return (a.frame - b.frame); } );
		return self;
	}
	
	/// @ignore
	/// @desc Reinicia por completo el manager.
	static replay = function()
	{
		array_foreach(events, function(v, i) {
			var _in = v.inRep, _ou = v.ouRep;
			// Restablecer el valor de in y out.
			v.inVal = (is_array(_in) ) ? _in[irandom(array_length(_in) - 1) ] : _in;
			v.ouVal = (is_array(_ou) ) ? _ou[irandom(array_length(_ou) - 1) ] : _ou;
			// Establecer escala de tiempo
			v.setTimeScale(timeScale, useSeconds);
			// Cambiar valores.
			v.ready =   false;
			// Indicar que nunca se ha inicializado.
			v.started = false; 
		});
		
		// Poner indice de evento en 0
		index =      0;
		frameCount = 0;
		fnEndReady = false;
		
		return self;
	}
	
	#endregion
	
	#endregion
}

/** @desc  
    Vuelta! es un sistema que permite ejecutar "eventos" secuenciados uno tras el otro. 
    Las Vueltas se deben de iniciar utilizando el metodo .start() o usando vt_start
*/
/// @param {string}               name        Nombre de este VueltaManager
/// @param {array<Struct.Vuelta>} events      Array de eventos
/// @param {bool}                 [seconds]   =true usar segundos(true) o steps(false)
/// @param {real}                 [timeScale] =1 Dilatacion de tiempo
function vuelta(_name, _events, _useSeconds, _timeScale)
{
	return (new VueltaManager(_name, _events, _useSeconds, _timeScale) );
}
