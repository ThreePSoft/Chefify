using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class UserService(AppDbContext context)
{
    public async Task<IEnumerable<UserPreviewDto>> GetAllUsers()
    {
        var users = await context.Users
            .Select(u => new UserPreviewDto
            {
                Id = u.Id,
                Username = u.Username,
                ProfilePictureRef = u.ProfilePictureRef,
            })
            .ToListAsync();
        return users;
    }

    public async Task<User?> GetUser(int id)
    {
        return await context.Users.FirstOrDefaultAsync(u => u.Id == id);
    }

    public async Task<User?> UpdateProfile(int id, UpdateUserProfileDto dto)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (user == null)
        {
            return null;
        }

        user.Username = dto.Username.Trim();
        await context.SaveChangesAsync();
        return user;
    }

    public static UserDto ToDto(User user)
    {
        var userDto = new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            ProfilePictureRef = user.ProfilePictureRef
        };
        
        return userDto;
    }

    public async Task<User?> GetUserEntity(int id)
    {
        return await context.Users
            .Include(u => u.Recipes)
                .ThenInclude(r => r.Creator)
            .Include(u => u.Recipes)
                .ThenInclude(r => r.Category)
            .Include(u => u.Recipes)
                .ThenInclude(r => r.Tags)
            .Include(u => u.Recipes)
                .ThenInclude(r => r.Rating)
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    public IEnumerable<RecipePreviewDto> GetUserRecipes(User user)
    {
        var recipes = user.Recipes.Select(r => new RecipePreviewDto
            {
                Id = r.Id,
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                Rating = r.Rating.Avg,
                CategoryName = r.Category != null ? r.Category.Name : null,
                Tags = r.Tags.Select(t => t.Name).ToList(),
                CreatorId = r.CreatorId,
                CreatorUsername = r.Creator.Username
            })
            .ToList();

        return recipes;
    }

    public async Task UpdateUser(User user, AdminUserDto dto)
    {
        user.Role = dto.Role;
        user.Username = dto.Username;
        
        context.Users.Update(user);
        await context.SaveChangesAsync();
    }
}
