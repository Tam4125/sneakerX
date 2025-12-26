package com.example.sneakerx.mappers;

import com.example.sneakerx.dtos.user.UserAddressDto;
import com.example.sneakerx.entities.UserAddress;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserAddressMapper {

    public UserAddressDto mapToUserAddressDto(UserAddress userAddress) {
        UserAddressDto userAddressDto = new UserAddressDto();
        userAddressDto.setAddressId(userAddress.getAddressId());
        userAddressDto.setRecipientName(userAddress.getRecipientName());
        userAddressDto.setPhone(userAddress.getPhone());
        userAddressDto.setProvinceOrCity(userAddress.getProvinceOrCity());
        userAddressDto.setDistrict(userAddress.getDistrict());
        userAddressDto.setWard(userAddress.getWard());
        userAddressDto.setAddressLine(userAddress.getAddressLine());
        userAddressDto.setUserId(userAddress.getUser().getUserId());

        return userAddressDto;
    }
}
