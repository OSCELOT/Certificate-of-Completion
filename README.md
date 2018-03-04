# Certificate-of-Completion

## Description

The Certificate of Completion tool is used for displaying a certificate bearing the name of an individual student or participant of a course. The certificate displays as an image on the screen and can be printed if required. When a student/participant views the certificate, his/her own name and user ID will be displayed on that certificate along with the current date.

## Summary

|     |     |
| --- | --- |
| **Lead Developer(s)** | Dale Hansen |
| **Development Status** | Production/Stable |
| **License** | GNU Lesser General Public License (LGPL) |
| **Programming Language** | Java |
| **Target Platform** | Blackboard Learn 9.1 |

## Installation
This repository contains all of the source files, but for installation, you just need the "gu-certofcomp.war" file. Follow the "Install or Update Building Block" instructions at https://help.blackboard.com/Learn/Administrator/Hosting/Tools_Management/Install_and_Manage_Building_Blocks for uploading this .war file to your Blackboard Learn environment.

## Documentation

Available at https://intranet.secure.griffith.edu.au/computing/using-learning-at-griffith/staff/administration/certificate-of-completion

## Source Code

Available at https://github.com/OSCELOT/Certificate-of-Completion/

## Compatibility

This Building Block has only been tested with Blackboard Learn 9.1. A version needed to be specified in the bb-manifest in order for the Building Block to work. If you wish to test it with a different version, you would need to specify a different version value in the line <bbversion value="9.1"/> of bb-manifest.xml (within WebContent/WEB-INF) and recompile the Building Block (.war file).

## Disclaimer

This Building Block is offered under a GNU General Public Licence. No responsibility is taken for your use of this Building Block by the developer. You must ensure sufficient testing has taken place on your testing environment to ensure this Building Block is compatible with your specific Blackboard environment and its settings.
