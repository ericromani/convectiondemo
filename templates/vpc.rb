require 'convection'

module Templates
  VPC = Convection.template do
    description 'VPC with Public and Private Subnets (NAT)'

    ec2_vpc 'DemoVPC' do
      network '10.10.10.0/23'
      tag 'Name', "#{stack.cloud}-#{stack.name}"
      enable_dns true
    end

    ec2_subnet 'PrivateSubnet' do
      network '10.10.10.0/24'
      tag 'Name', "#{stack.cloud}-#{stack.name}-private"
      vpc fn_ref('DemoVPC')
    end

    ec2_subnet 'PublicSubnet' do
      network '10.10.11.0/24'
      tag 'Name', "#{stack.cloud}-#{stack.name}-public"
      vpc fn_ref('DemoVPC')
      public_ips true
    end

    ec2_security_group 'NATSecurityGroup' do
      description 'NAT access for private subnet'
      vpc fn_ref('DemoVPC')
      tag 'Name', "#{stack.cloud}-#{stack.name}-nat-security-group"
      ingress_rule :tcp, 443 do
        source '10.10.10.0/24'
      end
      ingress_rule :tcp, 80 do
        source '10.10.10.0/24'
      end
      egress_rule :tcp, 443 do
        source '0.0.0.0/0'
      end
      egress_rule :tcp, 80 do
        source '0.0.0.0/0'
      end
    end

    ec2_instance 'NATInstance' do
      tag 'Name', "#{stack.cloud}-#{stack.name}-nat"
      image_id 'ami-258e1f33'
      instance_type 't2.small'
      subnet fn_ref('PublicSubnet')
      security_group fn_ref('NATSecurityGroup')
      src_dst_checks false
    end


  end
end