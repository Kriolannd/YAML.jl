using Test, YAML, YAML.YAMLErrors


@testset "Correct YAML test" begin
    @testset "One document" begin
        @testset "Simple case" begin
            yaml_str = """
                name: Alice
                surname: Great
                middle_name: Bett
            """

            @test parse_yaml_str(yaml_str) == [Dict("name" => "Alice", "surname" => "Great", 
                                                    "middle_name" => "Bett")]

            yaml_str = """
                你好: 世界
            """

            @test parse_yaml_str(yaml_str) == [Dict("你好" => "世界")]
        end

        @testset "Comments case" begin
            yaml_str = """
                # It is weird but okay
                name: Alice
            """

            @test parse_yaml_str(yaml_str) == [Dict("name" => "Alice")]

            yaml_str = """
                # It is weird but okay
                name: Alice # so is this
                # but okay
            """

            @test parse_yaml_str(yaml_str) == [Dict("name" => "Alice")]
        end

        @testset "Type tags" begin
            yaml_str = """
                name: Alice
                date: !!timestamp 2023-08-22
                count: !!int 20
            """

            @test parse_yaml_str(yaml_str) == [Dict(
                                                    "name" => "Alice", 
                                                    "date" => "2023-08-22",
                                                    "count" => "20",)]
        end

        @testset "Strings" begin
            yaml_str = """
                text1: | 
                    This is a string. It may contain multiple
                    sentences and etc.
                text2: >
                    So is this one, which can contain same multiple
                    sentences.
                text3: This is a short string.
            """

            test_dict = Dict(
                "text1" => "This is a string. It may contain multiple\nsentences and etc.\n",
                "text2" => "So is this one, which can contain same multiple sentences.\n",
                "text3" => "This is a short string."
            )

            @test parse_yaml_str(yaml_str) == [test_dict, ]
        end

        @testset "Sequences" begin
            yaml_str = """
                fruits_multiline:
                    - apple
                    - banana
                    - orange
                fruits_oneline: [pineapple, banana, orange]
            """

            test_dict = Dict(
                "fruits_multiline" => ["apple", "banana", "orange"],
                "fruits_oneline" => ["pineapple", "banana", "orange"],
            )

            @test parse_yaml_str(yaml_str) == [test_dict, ]
        end

        @testset "Mappings" begin
            yaml_str = """
                person1:
                    name: John Doe
                    age: 30
                    contact:
                        email: john@example.com
            """

            test_dict = Dict(
                "person1" => Dict(
                    "name" => "John Doe",
                    "age" => "30",
                    "contact" => Dict("email" => "john@example.com")
                )
            )

            @test parse_yaml_str(yaml_str) == [test_dict, ]
        end

        @testset "Anchors" begin
            yaml_str = """
            person: &details
                name: John Doe
                age: 30

            employee1:
                <<: *details
                position: Developer
            """

            test_dict = Dict(
                "person" => Dict(
                    "name" => "John Doe",
                    "age" => "30",
                ),
                "employee1" => Dict(
                    "<<" => Dict(
                        "name" => "John Doe",
                        "age" => "30",
                    ),
                    "position" => "Developer",
                )
            )

            @test parse_yaml_str(yaml_str) == [test_dict, ]
        end
    end

    @testset "Multiple documents" begin
        yaml_str = """
        name: Alice
        surname: Great
        middle_name: Bett

        ---
        person1:
            name: John Doe
            age: 30
            contact:
                email: john@example.com

        ---
        person: &details
            name: John Doe
            age: 30
        employee1:
            <<: *details
            position: Developer
        """

        test_dict_1 = Dict(
            "name" => "Alice", 
            "surname" => "Great", 
            "middle_name" => "Bett",
        )

        test_dict_2 = Dict(
            "person1" => Dict(
                "name" => "John Doe",
                "age" => "30",
                "contact" => Dict("email" => "john@example.com")
            )
        )

        test_dict_3 = Dict(
            "person" => Dict(
                "name" => "John Doe",
                "age" => "30",
            ),
            "employee1" => Dict(
                "<<" => Dict(
                    "name" => "John Doe",
                    "age" => "30",
                ),
                "position" => "Developer",
            )
        )

        @test parse_yaml_str(yaml_str) == [test_dict_1, test_dict_2, test_dict_3]
    end
end
