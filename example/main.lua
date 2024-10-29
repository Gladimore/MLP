local date = os.date("*t")
local time = os.clock() * 1e6
local seed = date.sec + time

math.randomseed(seed)

local MLP = require("mlp")

local names = {
  [1] = "Horizontal",
  [2] = "Vertical",
  [3] = "Diagonal"
}

local function max(...)
  local t = { ... }
  local max_v = t[1]
  local index = 1

  for i = 2, #t do
    local v = t[i]

    if v > max_v then
      max_v = v
      index = i
    end
  end

  return max_v, index
end

local function addAnomalousPatterns(dataset)
  local extendedDataset = {}

  -- First, copy all original patterns
  for i, data in ipairs(dataset) do
      extendedDataset[i] = data
  end

  -- Now add anomalous versions
  local numNewPatterns = math.random(1, #dataset)
  for i = 1, numNewPatterns do
      local originalIndex = math.random(1, #dataset)
      local newData = {grid = {}, label = {}}

      -- Copy the selected pattern
      for row = 1, 3 do
          newData.grid[row] = {}
          for col = 1, 3 do
              newData.grid[row][col] = dataset[originalIndex].grid[row][col]
          end
      end

      -- Copy label
      for j = 1, #dataset[originalIndex].label do
          newData.label[j] = dataset[originalIndex].label[j]
      end

      -- Add random anomaly
      local row = math.random(1, 3)
      local col = math.random(1, 3)
      newData.grid[row][col] = newData.grid[row][col] == 0 and 1 or 0

      -- Add to extended dataset
      table.insert(extendedDataset, newData)
  end

  return extendedDataset
end

-- Function to flatten a 3x3 grid into a 1D vector
local function flatten(grid)
  local flat = {}
  for i = 1, 3 do
    for j = 1, 3 do
      table.insert(flat, grid[i][j])
    end
  end
  return flat
end

local dataset = addAnomalousPatterns(require("dataset")) -- 3x3

-- Flatten the dataset
local inputs, targets = {}, {}
for _, data in ipairs(dataset) do
  table.insert(inputs, flatten(data.grid))
  table.insert(targets, data.label)
end

-- MLP configuration
local input_size = 9         -- 3x3 grid, flattened to 9 elements
local output_size = 3        -- Three classes (horizontal, vertical, diagonal)
local hidden_sizes = { 8 } -- One hidden layer with 8 neurons
local learning_rate = 0.01

-- Initialize MLP
local mlp = MLP.new(input_size, hidden_sizes, output_size, learning_rate)
mlp.printLoss = false

-- Train the MLP
local epochs = 1000
local last_loss, train_time = mlp:train(inputs, targets, epochs)

local format = string.format("Last Loss: %.4f | Training Time: %.5f second(s)", last_loss, train_time)

print(format)

-- Test the MLP
for i, input in ipairs(inputs) do
  local output = mlp:forward(input)
  local _, predicted = max(table.unpack(output))
  local predicted_name = names[predicted]

  local _, actual = max(table.unpack(targets[i]))
  local actual_name = names[actual]

  local formatted = string.format("Input: %s, Predicted: %s, Actual: %s", i, predicted_name, actual_name)

  print(formatted)
end
