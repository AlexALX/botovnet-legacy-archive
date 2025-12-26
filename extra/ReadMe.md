# PHP-Fusion Plugins for VIP System and Online Shop

## Overview

This repository contains **PHP-Fusion plugins** that were part of the **VIP system and online shop** used for:

- **Rust servers** — managing VIP access, in-game purchases, personal stat.  
- **Online chat display** — communication from website.
- **Steam Sign-in** - allow sign in using steam (required for VIP)

These plugins include versions for **PHP-Fusion v6.01** and **v7.02**, designed to integrate with the CMS and the server-side systems.

Any media (images) was EXCLUDED from this repository.
Some files include configuration placeholders such as API keys and require adjustment before real use.

---

## Plugins Included

| Plugin | PHP-Fusion Version | Purpose / Notes |
|--------|------------------|----------------|
| VIP Plugin | v6.01 | Handles VIP purchases, server integration |
| VIP Chat Display | v6.01 | Shows VIP players and admin messages in chat |
| Monitoring System | v7.02 | Monitoring system for rust/gmod/cs 1.6 servers |

> Check individual plugin files for detailed installation instructions and license information.

---

## License

- **PHP-Fusion v6.01 plugins** — GNU GPL v2  
- **PHP-Fusion v7.02 plugins** — Affero GPL (AGPL)  

> These plugins are **distributed under their original licenses**.  
> You may use and modify them according to the terms of each license.

---

## Installation

1. Copy the plugin files to your PHP-Fusion installation (`includes/infusions/`).  
2. Activate the plugin via **Admin Panel → Infusions**.  
3. For Rust and gmod there is extra MySQL dump game_stat_dump.sql for game stats.

---

## Important Notes

- These plugins were developed as part of the **Botov-NET VIP system**.  
- Do **not redistribute or sell** without complying with the respective license.  
- Ensure compatibility with your PHP-Fusion version before installation.  
- No warranties are provided; use at your own risk.

---

## References

- PHP-Fusion: [https://www.php-fusion.co.uk/](https://www.php-fusion.co.uk/)  
- GNU GPL v2: [https://www.gnu.org/licenses/old-licenses/gpl-2.0.html](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)  
- Affero GPL (AGPL): [https://www.gnu.org/licenses/agpl-3.0.html](https://www.gnu.org/licenses/agpl-3.0.html)
