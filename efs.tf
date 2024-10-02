#resource "aws_efs_file_system" "jenkins_efs" {
#    lifecycle_policy {
#        transition_to_ia = "AFTER_30_DAYS"
#    }
#
#    tags = {
#        Name = "jenkins-efs"
#    }
#}
#
#resource "aws_efs_mount_target" "jenkins_master_mount" {
#    file_system_id  = aws_efs_file_system.jenkins_efs.id
#    subnet_id       = aws_subnet.public.id
#    security_groups = [aws_security_group.efs_sg.id]
#}

#resource "aws_efs_mount_target" "jenkins_agent1_mount" {
#    file_system_id  = aws_efs_file_system.jenkins_efs.id
#    subnet_id       = aws_subnet.public.id
#    security_groups = [aws_security_group.efs_sg.id]
#}

#resource "aws_efs_mount_target" "jenkins_agent2_mount" {
#    file_system_id  = aws_efs_file_system.jenkins_efs.id
#    subnet_id       = aws_subnet.public.id
#    security_groups = [aws_security_group.efs_sg.id]
#}
