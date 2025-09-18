# ⚡ EletroCast Framework

A comprehensive FiveM framework that combines the best features of VRP and QBCore frameworks, utilizing ox_lib for UI components and oxmysql for database operations.

## 🎯 Overview

EletroCast Framework is a modern, feature-rich FiveM framework designed to provide developers with a solid foundation for their roleplay servers. It combines the user identification system from VRP with the job system from QBCore, while leveraging the power of ox_lib for UI components and oxmysql for database operations.

## ✨ Key Features

### 🔐 Player Management System (VRP-style)
- **Multi-character Support**: Up to 3 characters per player (configurable)
- **Steam/License Identification**: Secure player identification using multiple identifiers
- **Character Creation/Selection**: Intuitive character management with ox_lib UI
- **Persistent Data**: All character data is automatically saved and synchronized
- **Permission System**: Hierarchical group-based permissions

### 💼 Job System (QBCore-style)
- **Dynamic Job Management**: Easy job creation and modification
- **Grade System**: Multiple grades per job with different permissions and payments
- **Boss Actions**: Hire, fire, promote, and demote employees
- **Duty System**: On/off duty mechanics with different behaviors
- **Whitelisted Jobs**: Special jobs requiring approval (Police, EMS, etc.)
- **Job Centers**: Interactive locations for job changes

### 🎒 Advanced Inventory System
- **Item-based Inventory**: Comprehensive item system with metadata support
- **Weight/Slot Limitations**: Realistic inventory constraints
- **Item Usage Callbacks**: Custom item effects and interactions
- **Stash System**: Persistent storage containers
- **Drop/Pickup System**: World interaction with items
- **Give System**: Transfer items between players

### 💰 Economy System
- **Multiple Money Types**: Cash, Bank, and Dirty Money
- **Transaction Logging**: Complete audit trail of all transactions
- **Tax System**: Configurable tax rates for different transaction types
- **Banking System**: ATMs and bank locations with full functionality
- **Business Ownership**: Player-owned businesses with employee management
- **Paycheck System**: Automatic salary payments with tax deductions

### 🗃️ Database Management
- **MySQL Integration**: Full oxmysql integration with prepared statements
- **Optimized Queries**: Efficient database operations
- **Transaction Support**: Safe multi-query operations
- **Automatic Cleanup**: Scheduled maintenance tasks
- **Data Integrity**: Foreign key constraints and data validation

### 🎨 User Interface (ox_lib)
- **Modern UI Components**: Context menus, progress bars, notifications
- **Mobile-Responsive**: Adaptive UI for different screen sizes
- **Accessibility**: WCAG compliant interface elements
- **Themeable**: Dark/light theme support
- **Customizable**: Easy to modify and extend

## 📋 Requirements

- **FiveM Server**: Latest recommended version
- **ox_lib**: For UI components and utilities
- **oxmysql**: For database operations
- **MySQL/MariaDB**: Database server

## 🚀 Installation

### 1. Download and Setup
```bash
# Clone or download the framework to your resources folder
# Ensure the folder is named 'framework'
```

### 2. Database Setup
```sql
-- Execute the SQL file to create all required tables
-- File: framework/sql/framework.sql
```

### 3. Configuration
```lua
-- Edit framework/config/config.lua
Config.MySQL = {
    UseOxMySQL = true,
    Host = 'localhost',
    Database = 'your_database_name',
    Username = 'your_username',
    Password = 'your_password'
}
```

### 4. Server Configuration
Add to your `server.cfg`:
```bash
# Dependencies (must be started before framework)
ensure ox_lib
ensure oxmysql

# Framework
ensure framework
```

### 5. Permissions Setup
Configure admin permissions in your server configuration or through the framework's permission system.

## ⚙️ Configuration

### Main Configuration (`config/config.lua`)
```lua
Config.FrameworkName = "EletroCast Framework"
Config.UseMultiCharacter = true
Config.MaxCharacters = 3
Config.StartingCash = 5000
Config.StartingBank = 25000
Config.MaxInventorySlots = 35
Config.MaxInventoryWeight = 120000
```

### Jobs Configuration (`config/jobs.lua`)
```lua
Jobs['police'] = {
    label = 'Los Santos Police Department',
    type = 'leo',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {name = 'Cadet', payment = 750, isboss = false},
        [1] = {name = 'Officer', payment = 1000, isboss = false},
        -- ... more grades
    }
}
```

### Items Configuration (`config/items.lua`)
```lua
Items['bandage'] = {
    name = 'bandage',
    label = 'Bandage',
    weight = 150,
    type = 'item',
    unique = false,
    useable = true,
    description = 'Medical bandage for treating minor wounds'
}
```

## 🔧 API Reference

### Server-Side Functions

#### Player Management
```lua
-- Get player data
local playerData = exports['framework']:GetPlayer(source)

-- Add money to player
exports['framework']:AddMoney(source, amount, 'cash', 'reason')

-- Remove money from player
exports['framework']:RemoveMoney(source, amount, 'bank', 'reason')

-- Set player job
exports['framework']:SetPlayerJob(source, 'police', 2)
```

#### Inventory Management
```lua
-- Add item to player
exports['framework']:AddItem(source, 'bandage', 5)

-- Remove item from player
exports['framework']:RemoveItem(source, 'bandage', 1)

-- Check if player has item
local hasItem = exports['framework']:HasItem(source, 'bandage', 2)
```

#### Database Operations
```lua
-- Get user data
exports['framework']:GetUser(identifier, function(userData)
    -- Handle user data
end)

-- Create character
exports['framework']:CreateCharacter(characterData, function(characterId)
    -- Handle character creation
end)
```

### Client-Side Functions

#### UI Components
```lua
-- Show notification
exports['framework']:Notify('Message', 'success', 5000)

-- Show progress bar
local success = exports['framework']:ProgressBar({
    duration = 5000,
    label = 'Processing...',
    canCancel = true
})

-- Show context menu
exports['framework']:ShowContextMenu('menu_id', 'Title', options)

-- Input dialog
local input = exports['framework']:InputDialog('Header', inputs)
```

#### Player Functions
```lua
-- Get player data
local playerData = exports['framework']:GetPlayerData()

-- Check if player is loaded
local isLoaded = exports['framework']:IsPlayerLoaded()

-- Open inventory
exports['framework']:OpenInventory()
```

## 📊 Database Schema

### Core Tables
- **users**: Player identification and basic data
- **characters**: Character-specific information
- **character_inventory**: Player inventories
- **items**: Item definitions and properties
- **jobs**: Job configurations
- **vehicles**: Owned vehicles
- **businesses**: Player-owned businesses
- **transactions**: Financial transaction logs
- **stashes**: Persistent storage containers

## 🎮 Commands

### Admin Commands
```bash
/givemoney [player_id] [amount] [money_type] # Give money to player
/setmoney [player_id] [amount] [money_type]  # Set player money
/giveitem [player_id] [item] [amount]        # Give item to player
/job [player_id] [job_name] [grade]          # Set player job
/car [vehicle_model]                         # Spawn vehicle
/tp [x] [y] [z]                             # Teleport to coordinates
```

### Player Commands
```bash
/players    # Check online player count
/coords     # Get current coordinates (admin)
/duty       # Toggle job duty status
/bossmenu   # Open boss actions menu
/employees  # Check job employee status
```

### Keybinds
- **TAB**: Open Inventory
- **F1**: Open Phone
- **F6**: Job Menu
- **G**: Job-specific actions (context-sensitive)

## 🔌 Events

### Server Events
```lua
-- Player loaded
RegisterNetEvent('ec:server:playerLoaded', function(source, playerData) end)

-- Job updated
RegisterNetEvent('ec:server:jobUpdated', function(source, jobName, grade) end)

-- Money transaction
RegisterNetEvent('ec:server:transactionLogged', function(source, type, amount, moneyType, reason) end)
```

### Client Events
```lua
-- Player spawned
RegisterNetEvent('ec:client:playerSpawned', function() end)

-- Character loaded
RegisterNetEvent('ec:client:characterLoaded', function(character) end)

-- Job updated
RegisterNetEvent('ec:client:jobUpdated', function(jobData) end)
```

## 🧩 Extending the Framework

### Adding Custom Jobs
1. Add job configuration to `config/jobs.lua`
2. Create job-specific logic in `client/jobs.lua`
3. Add server-side job handling in `server/jobs.lua`
4. Update database if needed

### Creating Custom Items
1. Add item definition to `config/items.lua`
2. Insert item data into database
3. Add usage logic in `server/inventory.lua`
4. Create client-side effects if needed

### Custom UI Components
```lua
-- Register custom context menu
ECUI.ShowContextMenu('custom_menu', 'Custom Title', {
    {
        title = 'Option 1',
        description = 'Description',
        icon = 'icon-name',
        onSelect = function()
            -- Handle selection
        end
    }
})
```

## 🛠️ Development Tools

### Debugging
```lua
-- Enable debug mode in config
Config.UseDebug = true

-- Use logging functions
ECUtils.Log('info', 'Debug message', {data = 'value'})
```

### Performance Monitoring
- Built-in performance metrics
- Database query optimization
- Memory usage tracking
- Event profiling

## 📚 Best Practices

### Database Operations
- Always use prepared statements
- Implement proper error handling
- Use transactions for multiple queries
- Regular cleanup of old data

### UI Development
- Follow ox_lib patterns
- Implement proper loading states
- Handle user input validation
- Ensure mobile compatibility

### Performance
- Minimize client-server communication
- Use efficient database queries
- Implement proper caching
- Profile resource usage regularly

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This framework is released under the MIT License. See LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Join our Discord community
- Check the documentation wiki

## 🙏 Credits

- **ox_lib**: For UI components and utilities
- **oxmysql**: For database operations
- **QBCore**: For job system inspiration
- **VRP**: For player management concepts
- **FiveM Community**: For continuous support and feedback

---

**Made with ❤️ by the EletroCast Team**