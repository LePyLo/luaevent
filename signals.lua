-- module to create basic signal connections (event driven)
local S = {
    connections = {}
}

-- function that connects a signal to a receiver and method
-- @param signal: string - the name of the signal to connect
-- @param receiver: object - the object that will receive the signal
-- @param method: string - the name of the method in the receiver that will be called
function S:connect(signal, receiver, method)
    if not self.connections[signal] then
        self.connections[signal] = {}
    end
    if not self.connections[signal][receiver] then
        self.connections[signal][receiver] = {}
    end
    --check if the receiver has the method
    local receiver_method = receiver[method]
    if type(receiver_method) == "function" then
        self.connections[signal][receiver][method] = true
    else
        error("El objeto receiver no contiene el methodo: " .. method)
    end
end
-- function that emits a signal to all connected receivers and methods
-- @param signal: string - the name of the signal to emit
-- @param ...: any - the arguments to pass to the receiver methods
function S:emitSignal(signal, ...)
    local listeners = self.connections[signal]
    if listeners then
        for receiver_object, methods in pairs(listeners) do
            for method_name, _ in pairs(methods) do
                pcall(function(...)
                    local receiver_method = receiver_object[method_name]
                    if type(receiver_method) == "function" then
                        receiver_method(receiver_object, ...)
                    else
                        error("El objeto receiver no contiene el methodo: " .. method_name)
                    end
                end, ...)
            end
        end
    else
        error("No hay conexiones registradas para la señal: " .. signal)
    end
end
-- function that disconnects a signal from a receiver and method
-- @param signal: string - the name of the signal to disconnect
-- @param receiver: object - the object that will receive the signal
-- @param method: string - the name of the method in the receiver that will be called
function S:disconnect(signal, receiver, method)
    if self.connections[signal] and self.connections[signal][receiver] then
        self.connections[signal][receiver][method] = nil
        if next(self.connections[signal][receiver]) == nil then
            self.connections[signal][receiver] = nil
            if next(self.connections[signal]) == nil then
                self.connections[signal] = nil
            end
        end
    end
end
-- function that disconnects all receivers from a signal
-- @param signal: string - the name of the signal to disconnect
function S:disconnectAll(signal)
    self.connections[signal] = nil
end
-- function that return the number of connections in the signal manager
function S:count()
    local total_connections = 0
    for _, receivers in pairs(self.connections) do
        for _, methods in pairs(receivers) do
            for _ in pairs(methods) do
                total_connections = total_connections + 1
            end
        end
    end
    return total_connections
end
-- function that return the number of receivers connected to a signal
-- @param signal_name: string - the name of the signal to count receivers
function S:countSignal(signal_name)
    if self.connections[signal_name] then
        local receiver_count = 0
        for _ in pairs(self.connections[signal_name]) do
            receiver_count = receiver_count + 1
        end
        return receiver_count
    else
        return 0
    end
end
function S:printConnections()
    for signal, receivers in pairs(self.connections) do
        print("* Signal:", signal)
        for receiver, methods in pairs(receivers) do
            print("> Receiver:", receiver," - ",receiver.type)
            for method, _ in pairs(methods) do
                print(">>  Method:", method)
            end
        end
    end
end
return S
