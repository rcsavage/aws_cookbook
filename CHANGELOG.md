aws_sdk CHANGELOG
=====================

This file is used to list changes made in each version of the aws_sdk cookbook.

0.4.7
-----
- [Rory Savage] - Added ebssnap for the ability to create snap-shots with ebssnap 

0.4.5
-----
- [Rory Savage] - Refactored aws_sdk/providers/ebs.rb to work with existing enviornment volume configurations.  This allows the admin to define volumes in a chef enviornment so that recipes can co-exist between different envs.   

0.4.4
-----
- [Rory Savage] - QA Testing of EBS

0.4.3
-----
- [Rory Savage] - Initial EBS work

0.4.1
-----
- [Rory Savage] - Updates to include baked required Ruby Gems (nokogiri, mini_portile, and aws_sdk).  Refactored the default.rb recipe to include GEMS.clear_path upon gem install (this would normally break a chef run if an install was needed).

0.3.0
-----
- [Rory Savage] - Major Updates, renamed aws-sdk to aws_sdk.  Also created the elb LWRP for reusable code, and general Cookbook practice.   This can be expanded upon for futher AWS related functionality like EBS volume management, etc.

0.2.0
-----
- [Rory Savage] - Initial release of aws_sdk promoted from poc-aws-sdk.

