# DEPLOY REQUIREMENTS

🚀
<br>

> Deploy requirements for IH-IT software
> <br>

## App Template

    - Website

## System

    - Windows

## Environment

    - Dev
    - Prod

## ANSIBLE RECIPE NAME

_Production_

    - Deploy MassTransit.App - PROD

_Development_

    - Deploy MassTransit.App - DEV

## App folder

`ScreeningTool.MassTransit.App`

## Distribution

    - Main
    - Tag

## Settings site

    - feature_net45: 'no'
    - net_core: 'no'
    - core_version: 'no'
    - httpplatform: 'no'
    - managedRuntimeVersion_pool: 'no managed'
    - enable32BitAppOnWin64_pool: 'false'
    - managedPipeLineMode_pool: 'integrated'
    - iiswin_aut: 'no'
    - thredds_whitelist: 'si'

## LOG

    - log: 'no'

## Url GIT

    - ssh  git@github.com:IHCantabria/ScreeningTool.MassTransit.App.git

## DNS

_Production_

    - masstransittool.ihcantabria.com

_Development_

    - masstransittooldev.ihcantabria.com

## Other settings

Select only if needed:

**Binary repo**

`_____________`

**Services to restart**

`_____________`

**Backup**

---

**Do you need any other configuration?**

<br>

## Relationships

**What applications, services, or data sources is this application related to?**

`ScreeningTool.MassTransit.Api`, `thredds`

## Credits

[IH Cantabria](https://github.com/IHCantabria)

## FAQ

- Document provided by the system administrators [David del Prado](https://ihcantabria.com/directorio-personal/tecnologo/david-del-prado-secadas/) y [Gloria Zamora](https://ihcantabria.com/directorio-personal/tecnologo/gloria-zamora/)
