require("eawx-std/class")

---@class Queue A First-In-First-Out Collection Data Structure
---@field size number The number of elements in the Queue
Queue = class()

function Queue:new()
    self.__elements = {}
    self.size = 0
end

---Adds a new element to the end of the Queue
---@param element any
function Queue:add(element)
    table.insert(self.__elements, element)
    self.size = table.getn(self.__elements)
end

---Removes the element at the given index from the Queue and returns it. If no index is given removes the first element from the Queue
---@return any
---@overload fun()
function Queue:remove(index)
    if self.size == 0 then
        return nil
    end

    local element = table.remove(self.__elements, index or 1)
    self.size = table.getn(self.__elements)

    return element
end

---Returns the element at the given index in the Queue. If no index is given returns the first element in the Queue
---@return any
---@overload fun()
function Queue:peek(index)
    if self.size == 0 then
        return nil
    end

    local element = self.__elements[index or 1]

    return element
end

---Clears all elements from the Queue
function Queue:clear()
    self.__elements = {}
    self.size = 0
end

---Provides an iterator over the Queue that can be used in a for loop
function Queue:iter()
    return next, self.__elements, nil
end
