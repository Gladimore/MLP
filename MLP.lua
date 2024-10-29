-- Activation functions
local function relu(x)
    return x > 0 and x or 0
end

local function relu_derivative(x)
    return x > 0 and 1 or 0
end

local function softmax(outputs)
    local exp_sum = 0
    local temp = {}

    for i = 1, #outputs do
        temp[i] = math.exp(outputs[i])
        exp_sum = exp_sum + temp[i]
    end

    local inv_sum = 1 / exp_sum
    for i = 1, #outputs do
        outputs[i] = temp[i] * inv_sum
    end

    return outputs
end

local function random_weight()
    return math.random() * 2 - 1
end

local Layer = {}
Layer.__index = Layer

function Layer.new(input_size, output_size)
    local layer = setmetatable({}, Layer)
    layer.weights = {}
    layer.biases = {}

    for i = 1, output_size do
        layer.weights[i] = {}
        for j = 1, input_size do
            layer.weights[i][j] = random_weight()
        end
        layer.biases[i] = random_weight()
    end

    layer.inputs = {}
    layer.outputs = {}
    layer.gradients = {}

    return layer
end

function Layer:forward(inputs)
    self.inputs = inputs
    self.outputs = {}

    for i = 1, #self.weights do
        local sum = self.biases[i]
        for j = 1, #inputs do
            sum = sum + self.weights[i][j] * inputs[j]
        end
        self.outputs[i] = relu(sum)
    end

    return self.outputs
end

function Layer:backward(output_gradients, learning_rate)
    local input_gradients = {}

    for j = 1, #self.inputs do
        input_gradients[j] = 0
    end

    for i = 1, #self.outputs do
        local grad_output = output_gradients[i] * relu_derivative(self.outputs[i])
        for j = 1, #self.inputs do
            input_gradients[j] = input_gradients[j] + grad_output * self.weights[i][j]
            self.weights[i][j] = self.weights[i][j] - learning_rate * grad_output * self.inputs[j]
        end
        self.biases[i] = self.biases[i] - learning_rate * grad_output
    end

    return input_gradients
end

local MLP = {}
MLP.__index = MLP

function MLP.new(input_size, hidden_sizes, output_size, learning_rate)
    local mlp = setmetatable({}, MLP)
    mlp.learning_rate = learning_rate
    mlp.printLoss = true
    mlp.layers = {}

    local layer_sizes = { input_size, table.unpack(hidden_sizes), output_size }
    for i = 1, #layer_sizes - 1 do
        table.insert(mlp.layers, Layer.new(layer_sizes[i], layer_sizes[i + 1]))
    end

    return mlp
end

function MLP:forward(inputs)
    local outputs = inputs
    for i = 1, #self.layers - 1 do
        outputs = self.layers[i]:forward(outputs)
    end
    outputs = softmax(self.layers[#self.layers]:forward(outputs))
    return outputs
end

function MLP:backward(target)
    local output_layer = self.layers[#self.layers]
    local output_gradients = {}

    for i = 1, #output_layer.outputs do
        output_gradients[i] = output_layer.outputs[i] - target[i]
    end

    for i = #self.layers, 1, -1 do
        output_gradients = self.layers[i]:backward(output_gradients, self.learning_rate)
    end
end

function MLP:train(inputs, targets, epochs)
    local last = 0
    local printLoss = self.printLoss

    local s = os.clock()

    for epoch = 1, epochs do
        local loss = 0
        for i = 1, #inputs do
            local output = self:forward(inputs[i])
            for j = 1, #output do
                loss = loss - targets[i][j] * math.log(output[j])
            end
            self:backward(targets[i])
        end

        last = loss
        if printLoss then
            print("Epoch " .. epoch .. ", Loss: " .. loss)
        end
    end
    local e = os.clock()

    return last, (e - s)
end

return MLP
