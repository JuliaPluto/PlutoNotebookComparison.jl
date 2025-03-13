module LoggingUtils

import Logging, LoggingExtras

_explain_context_logger(logger, context) = LoggingExtras.TransformerLogger(logger) do log
	merge(log, (; message = "$(context)$(log.message)"))
end

with_logging_context(f::Function, context) = 
    Logging.with_logger(
		f, 
		_explain_context_logger(Logging.current_logger(), context)
	)

end