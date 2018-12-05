import boto3

instances = [i for i in boto3.resource('ec2', region_name='us-west-2').instances.all()]

tags = ['Name',]

# Print instance_id of instances that do not have a list of Tags
for i in instances:
  for a in tags:
    if a not in [t['Key'] for t in i.tags]:
      print "Instance ID: " + i.instance_id + " with Missing Tag: " + a
      print "---------------------------------------"