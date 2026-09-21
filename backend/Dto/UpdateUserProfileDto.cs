using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class UpdateUserProfileDto
{
    [Required]
    [StringLength(50, MinimumLength = 3)]
    public required string Username { get; set; }
}
