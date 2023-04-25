# DEPLOY REQUIREMENTS

🚀
<br>

> Deploy requirements for IH-IT software
> <br>

## App Template

    - Release

## System

    - Windows
    - Linux

## Environment

    - Dev
    - Prod

## ANSIBLE RECIPE NAME

_Production_

    - Deploy app_name - PROD

_Development_

    - Deploy app_name - DEV

## App folder

`_____________`

## Distribution

    - Release

## Settings site

    - feature_net45: 'si'/'no'
    - net_core: 'si'/'no'
    - core_version: '3.1.1'/'3.1.3'/'other'/'no'
    - httpplatform: 'no'/'si'
    - managedRuntimeVersion_pool: 'no managed'/'v4.0'/'v2.0'
    - enable32BitAppOnWin64_pool: 'false'/'true'
    - managedPipeLineMode_pool: 'integrated'/'Classic'
    - iiswin_aut: 'no'/'si'
    - thredds_whitelist: 'no'/'si'

## LOG

    - log: 'no' / 'si'

## Url GIT

     la direccion en git.com va sin ssh (GITEA)
    - ssh  git@193.144.208.195:222/IT/nombre_aplicacion.git

## DNS

_Production_

    - app_name.ihcantabria.com

_Development_

    - app_namedev.ihcantabria.com

## URL APPLICATION

_Production_

    - app_name.ihcantabria.com/path

_Development_

    - app_namedev.ihcantabria.com/path

## Other settings

Select only if needed:

**Binary repo**

`_____________`

**Services to restart**

`_____________`

**Backup**

    - Tags
    - Snapshot
    - Clone/Backup

---

**Do you need any other configuration?**

- app_name here must be equal to name property inside package.json 
- Descargar Release: https://api.github.com/repos/IHCantabria/app_name/releases/tags/app_name-{{ version }}-{{ entorno }}.zip

<br>

## Relationships

**What applications, services, or data sources is this application related to?**

`_______________________________________________________________________________`

## Credits

[IH Cantabria](https://github.com/IHCantabria)

## FAQ

- Document provided by the system administrators [David del Prado](https://ihcantabria.com/directorio-personal/david-del-prado-secadas/), [Gloria Zamora](https://ihcantabria.com/directorio-personal/gloria-zamora/) y [Luis Gutierrez](https://ihcantabria.com/directorio-personal/luis-gutierrez/)
