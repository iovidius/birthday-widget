-- store birthdays in a list
birthdays = {}
DAYS_FORWARD = 3

-- load birthdays from file
function Initialize()
 
    -- NAME | YYYY? | MM | DD
    DATA = SKIN:MakePathAbsolute('birthdays.csv')
    for line in io.lines(DATA) do
        local name, year, month, day = line:match('%s*(.-),%s*(.-),%s*(.-),%s*(.-)$')
        birthdays[#birthdays + 1] = {name=name, year=tonumber(year), month=tonumber(month),day=tonumber(day)}
    end

    -- Sort data
    -- Custom comparison function for sorting
    local function customSort(a, b)
        -- Compare by month
        if a.month < b.month then
            return true
        elseif a.month > b.month then
            return false
        end
        
        -- If months are equal, compare by day
        if a.day < b.day then
            return true
        elseif a.day > b.day then
            return false
        end
        
        -- If months and days are equal, compare by name
        return a.name < b.name
    end

    table.sort(birthdays, customSort)

end

-- Return names + age
function GetNames()
    -- Get the current date
    currentDate = os.date("*t")
    currentYear = currentDate.year
    currentMonth = currentDate.month
    currentDay = currentDate.day


    -- Find entries corresponding to today's date
    todayEntries = {}

    for _, entry in ipairs(birthdays) do
        if entry.month == currentMonth and entry.day >= currentDay and entry.day <= currentDay + DAYS_FORWARD then
            table.insert(todayEntries, entry)
        end
    end

    if #birthdays == 0 then
        return 'No upcoming birthdays.'
    end

    local names = ''
    -- Print the entries corresponding to today's date
    for _, entry in ipairs(todayEntries) do
        age = ""
        if entry.year ~= nil then
            age = " (" .. currentYear - entry.year .. ") "
        end
        bday = ""
        if entry.day == currentDay then
            bday = ""
        end
        names = names .. entry.name .. bday .. age .. "\n"
    end

    return names
end

-- Return +1 / +2 / +3
function GetAnnotations()

    currentDate = os.date("*t")
    currentYear = currentDate.year
    currentMonth = currentDate.month
    currentDay = currentDate.day


    local annotations = ''
    diff = 0 -- difference in days
    prev = 0
    for _, entry in ipairs(todayEntries) do
        if entry.day ~= currentDay and entry.day ~= prev then
			-- TODO: Dec -> Jan
			local x = {year = currentYear, month = entry.month, day = entry.day}
			local y = {year = currentYear, month = currentMonth, day = currentDay}
			local time1 = os.time(x)
			local time2 = os.time(y)
			local difference_in_seconds = os.difftime(time1, time2)
			diff = difference_in_seconds / (60 * 60 * 24)
            annotations = annotations .. '+' .. math.floor(diff)
        end
        prev = entry.day
        annotations = annotations .. '\n'
    end

    return annotations
end

-- Return index for divider
function GetDividerIndex(i)
    diff = 0
    prev = 0
    n = 0
    for _, entry in ipairs(todayEntries) do
        if entry.day ~= currentDay and entry.day ~= prev then
            diff = diff + 1
        end
        prev = entry.day
        n = n + 1
        if diff == i then
            return 27 + 12.5 * n
        end
    end
    return -1
end
