// Feather ignore all
/** @desc
	Ejecuta varios eventos al mismo tiempo. Cuando todos estos eventos son completados avanza al siguiente evento.
	Este evento no es compatible con "replay".
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
	/// @desc Evento a ejecutar
	static event = function()
	{
		var _events = events, i;
		var _size =   array_length(_events);
		with (scope) {
			for (i=0; i<_size; i++) {
				var _event = _events[i];
				if (!_event.started) {
					// Funcion inicial del evento
					method(self, _event.fnStart) (true);
					_event.start(true);
				}
				// Ejecutar evento.
				var _execute = _event.event();
				// Eliminar para no ejecutar de nuevo.
				if (_execute) {
					// Ejecutar funcion final del evento.
					method(self, _event.fnEnd) ();
					// Al completarse eliminar de la lista de eventos.
					array_delete(_events, i, 1);
					_size--;
				}
			}
		}
		// Al no haber más eventos completar.
		size = _size;
		return (size <= 0);
	}
	
	/// @ignore
	static start = function()
	{
		// Re-obtener al manager.
		manager = getManager();
		size    = array_length(events);
		started = true;
		// Establecer manager y más variables a los eventos que ejecutará este pack.
		var i=0; repeat(size) {
			var _vt =   events[i];
			var _name = name + " pack[" + string(i++) + "]";
			// Poner nombre.
			_vt.setName(_name);
			// Establecer cada event a quien controla a el pack.
			_vt.setManager(direct);
		}
	}
}

