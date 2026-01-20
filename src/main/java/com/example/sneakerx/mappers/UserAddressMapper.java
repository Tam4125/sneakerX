package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.user.UserAddressDto;
import com.example.sneakerx.entities.UserAddress;
import com.example.sneakerx.entities.customClasses.AddressSnapshot;
import lombok.RequiredArgsConstructor;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;
import org.springframework.stereotype.Component;

@Mapper(
        componentModel = "spring"
)
public interface UserAddressMapper {
    @Mapping(source = "user.userId", target = "userId")
    @Mapping(source = "isDefault", target = "isDefault")
    UserAddressDto toUserAddressDto(UserAddress userAddress);

    AddressSnapshot toAddressSnapshot(UserAddress userAddress);
}
