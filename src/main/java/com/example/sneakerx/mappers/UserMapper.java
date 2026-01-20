package com.example.sneakerx.mappers;


import com.example.sneakerx.dtos.user.UserDto;
import com.example.sneakerx.entities.User;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserMapper {
    // MapStruct automatically calls .toString() for Enums
    // and automatically handles null checks (if role is null, dto.role becomes null safely)
    UserDto toUserDto(User user);
}
